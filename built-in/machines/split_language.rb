# encoding: UTF-8
class SplitLanguage < Machine
  def language (*languages)
    @languages = languages
  end
  
  def process_answers
    best, rest = answers.partition do |answer|
      @languages.include? answer.language
    end
    
    label best: best
    label rest: rest
  end
end
