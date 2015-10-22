require "./chess_helpers.rb"

class Piece
  include ChessHelpers
  attr_reader :position

  def initialize(game)
    @game     = game
    @position = [-1,-1]
    @possible_offsets = []
  end

  def add_to_board_at(pos_x, pos_y)
    @game.board.add_piece self, pos_x, pos_y
    @position = [pos_x, pos_y]
  end

  def possible_moves
  # - calculates all the possible target positions on the board
  #     based on the piece's current position
  # - communicates with the board to eliminate invalid moves
  current_position = position
  all_possible_moves = []

  @possible_offsets.each do |pos|
    target_pos = coord_add(current_position, pos)

    if target_pos[0] > 0 && target_pos[1] > 0

      all_possible_moves << target_pos
    end
  end

  all_possible_moves
end


end
