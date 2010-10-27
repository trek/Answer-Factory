class FakeBlueprint < NudgeBlueprint
  attr_reader :changes
  
  def initialize(parent = nil)
    @changes = []
    t = Time.now
    b = Guid.id
    super(parent || "#{b} at #{t.to_i.to_s}:#{t.usec.to_s}")
  end
  
  def changed(how)
    @changes.push(how)
    self
  end
  
  def language
    :Fake
  end
  
  def blending_crossover (other)
    FakeBlueprint.new(other.blueprint)
  end
  
  def delete_n_points_at_random (n)
    FakeBlueprint.new("-- fake -- ")
  end
  
  def mutate_n_points_at_random (n)
    FakeBlueprint.new("-- fake -- ")
  end
  
  def mutate_n_values_at_random (n)
    FakeBlueprint.new("-- fake -- ")
  end
  
  def point_crossover (other)
    FakeBlueprint.new("-- fake -- ")
  end
  
  def unwrap_block
    FakeBlueprint.new(self).changed('unwrap_block')
  end
  
  def wrap_block
    FakeBlueprint.new(self).changed('wrap_block')
  end
end
MockBlueprint = FakeBlueprint