def answer_factory(blueprint, attributes = nil)
  (blueprint.nil? || blueprint.empty?) ? blueprint = FakeBlueprint.new(blueprint) : nil
  # (id, blueprint, location, origin, parent_ids, created, archived)
  answer = Answer.new(Guid.id, blueprint, nil, nil, nil, nil, nil)
  answer.instance_variable_set("@scores", score_factory(attributes))
  return answer
end

def score_factory(scores)
  # (name, value, answer_id, scorer, created)
  hash = {}
  return hash unless scores
  scores.each do |name,value|
    hash[name] = Score.new(name, value, nil, nil, nil)
  end
  return hash
end