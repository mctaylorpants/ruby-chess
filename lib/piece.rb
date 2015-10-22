class Piece
  attr_reader :position
  attr_reader :game

  def initialize(game, position)
    @game     = game
    @position = position
  end
end
