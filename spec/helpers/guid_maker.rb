module Guid
  @id = 0
  def self.id
    @id += 1
    @id
  end
end