require "./chess_helpers.rb"

class Piece
  include ChessHelpers
  attr_reader :position

  def initialize(game)
    @game     = game
    @position = [-1,-1]
  end

  def add_to_board_at(pos_x, pos_y)
    @game.board.add_piece self, pos_x, pos_y
    @position = [pos_x, pos_y]
  end

end
