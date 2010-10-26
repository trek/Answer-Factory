# encoding: UTF-8
module MysqlAdapter
  require 'rubygems'
  require 'mysql'
  
  def set_database (db)
    @mysql = Mysql.connect(db['host'], db['user'], db['password'], db['name'], db['port'], db['socket'])
    @mysql.query_with_result = false
  end
  
  def migrate
    execute "CREATE TABLE answers (`id` int(10) unsigned NOT NULL AUTO_INCREMENT, `blueprint` mediumtext, `language` varchar(50) DEFAULT NULL, `location` varchar(100) DEFAULT NULL, `origin` varchar(100) DEFAULT NULL, `parents` varchar(50) DEFAULT NULL, `created` int(11) DEFAULT NULL, `archived` int(11) DEFAULT NULL, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8"
    execute "CREATE TABLE scores (`id` int(10) unsigned NOT NULL AUTO_INCREMENT, `name` varchar(50) DEFAULT NULL, `value` varchar(50) DEFAULT NULL, `scorer` varchar(100) DEFAULT NULL, `created` int(11) DEFAULT NULL, `answer_id` int(11) DEFAULT NULL, PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8"
    execute "CREATE TABLE cycle (`n` int(10) unsigned NOT NULL)"
    execute "INSERT INTO cycle (n) VALUES (1)"
    execute "CREATE TABLE changelog (`cycle` int(11) NOT NULL, `comment` text, `timestamp` datetime DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8"
  end
  
  def zap
    execute "TRUNCATE TABLE answers"
    execute "TRUNCATE TABLE scores"
    execute "TRUNCATE TABLE changelog"
    execute "UPDATE cycle SET n=1 LIMIT 1"
  end
  
  def cycle
    return @cycle if @cycle
    
    result = select "SELECT n FROM cycle LIMIT 1"
    @cycle = result.fetch_row[0].to_i
  end
  
  def cycle!
    execute "UPDATE cycle SET n=n+1 LIMIT 1"
    @cycle += 1 if @cycle
  end
  
  def log_comment (comment)
    execute "INSERT INTO changelog (cycle, comment, timestamp) VALUES (#{cycle},'#{comment.gsub(/'/,"\'")}','#{Time.now}')"
  end
  
  def answer_count
    result = select "SELECT COUNT(id) FROM answers"
    result.fetch_row[0].to_i
  end
  
  def count_answers_at_machine (location)
    result = select "SELECT COUNT(id) FROM answers WHERE location = '#{location}' AND archived IS NULL"
    result.fetch_row[0].to_i
  end
  
  def load_answers_at_machine (location, load_scores = false)
    answers = []
    
    if load_scores
      result = select <<-query
        SELECT a.id, a.language, a.blueprint, a.created, s3.name, s3.value
        FROM answers AS a
        LEFT OUTER JOIN (
          SELECT s2.name, s2.value, s2.answer_id
          FROM (
            SELECT s1.name, s1.value, s1.answer_id
            FROM scores AS s1
            ORDER BY s1.id DESC
          ) AS s2
          GROUP BY s2.answer_id, s2.name
          ORDER BY NULL
        ) AS s3
        ON a.id = s3.answer_id
        WHERE location = '#{location}'
        AND archived IS NULL
        ORDER BY a.id ASC
      query
      
      last_seen_answer_id = 0
      
      # each row is an answer (which may be a repeat) with 0 or 1 associated scores (scores are unique)
      while row = result.fetch_row
        id = row[0].to_i
        
        # add an answer if the row contains an answer that isn't a repeat of the last answer
        if id != last_seen_answer_id
          blueprint = Factory.const_get("#{row[1]}Blueprint").new(row[2].force_encoding("utf-8"))
          created = row[3].to_i
          
          answers << answer = Answer.new(id, blueprint, location, nil, nil, created, nil)
          
          last_seen_answer_id = id
        end
        
        # add a score if the row contains a score
        if name = row[4]
          name.force_encoding("utf-8")
          value = (row[5] == "Infinity") ? Factory::Infinity : row[5].to_f
          
          scores = answer.instance_variable_get(:@scores) || answer.instance_variable_set(:@scores, {})
          scores[name.to_sym] = Score.new(name, value, answer.id, nil, nil)
        end
      end
    else
      result = select <<-query
        SELECT id, language, blueprint, created
        FROM answers
        WHERE location = '#{location}'
        AND archived IS NULL
      query
      
      while row = result.fetch_row
        id = row[0].to_i
        blueprint = Factory.const_get("#{row[1]}Blueprint").new(row[2].force_encoding("utf-8"))
        created = row[3].to_i
        
        answers << Answer.new(id, blueprint, location, nil, nil, created, nil)
      end
    end
    
    answers
  end
  
  def save_answers (answers)
    return if answers.empty?
    
    existing_answer_values = []
    created_answer_values = []
    
    answers.each do |answer|
      raise unless answer.location
      
      if answer.id
        existing_answer_values << "(#{answer.id},'#{answer.location}',#{answer.archived || :NULL})"
      else
        created_answer_values << "('#{answer.blueprint.gsub(/'/,"\'")}','#{answer.language}','#{answer.location}','#{answer.origin}','#{answer.parent_ids.join("+")}',#{answer.created},#{answer.archived || :NULL})"
      end
    end
    
    unless existing_answer_values.empty?
      execute "INSERT INTO answers (id, location, archived) VALUES #{existing_answer_values.join(",")} ON DUPLICATE KEY UPDATE location=VALUES(location), archived=VALUES(archived)"
    end
    
    i = 0
    
    while i < created_answer_values.length
      start_index = i
      
      created_answer_values[i..-1].inject(0) do |query_length, string|
        break if (query_length += string.length + 1) > 900000
        i += 1
        query_length
      end
      
      execute "INSERT INTO answers (blueprint, language, location, origin, parents, created, archived) VALUES #{created_answer_values[start_index...i].join(",")}"
    end
  end
  
  def save_scores (scores)
    return if scores.empty?
    
    values = []
    
    scores.each do |score|
      values << "('#{score.name}','#{score.value}','#{score.scorer}','#{score.created}','#{score.answer_id}')"
    end
    
    execute "INSERT INTO scores (name, value, scorer, created, answer_id) VALUES #{values.join(",")}"
  end
  
  def execute (query)
    @mysql.query(query) unless query.empty?
  end
  
  def select (query)
    @mysql.query_with_result = true
    result = execute(query)
    @mysql.query_with_result = false
    result
  end
end
