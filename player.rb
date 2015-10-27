class Player
  attr_reader :name
  attr_reader :home_base
  attr_reader :num_moves

  def initialize(name, home_base)
    @name = name
    @home_base = home_base
    @num_moves = 0
  end

  def increment_move_count
    @num_moves += 1
  end
end
