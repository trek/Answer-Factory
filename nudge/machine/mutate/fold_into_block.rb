# encoding: UTF-8
module Machine::Nudge
  class FoldIntoBlock < Machine
    def process (answers)
      created = []
      
      answers.each do |parent|
        tree = NudgePoint.from(parent.blueprint)
        
        if points = tree.instance_variable_get(:@points)
          block_start, block_end = [rand(points.length), rand(points.length)].sort
          
          unless block_start == block_end
            block = BlockPoint.new(*points.slice!(block_start..block_end))
            points[block_start...block_start] = block
          end
        end
        
        created << Answer.new(tree.to_script, 'nudge', parent.progress + 1)
      end
      
      return :parents => answers,
             :created => created
    end
  end
end