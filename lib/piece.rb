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
  # - calculates all the possible target positions based on the piece's current
  #     position
  #
  # - this filters out values less than 1, for obvious reasons, but it will not
  #     filter out other coordinates that may be off the board. this should be
  #     the board's responsibility since it knows things like how big it is,
  #     as well as what other pieces may be in the way
  current_position = position
  all_possible_moves = []
  byebug
  @possible_offsets.each do |pos|
    target_pos = coord_add(current_position, pos)

    if target_pos[0] > 0 && target_pos[1] > 0
      all_possible_moves << target_pos
    end
  end

  all_possible_moves
end


end
