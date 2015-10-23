class Player
  attr_reader :name
  attr_reader :home_base

  def initialize(name, home_base)
    @name = name
    @home_base = home_base
  end
end
