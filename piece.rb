require "./chess_helpers.rb"

class Piece
  include ChessHelpers
  attr_accessor :position
  attr_reader :owner # which player owns this piece?
  attr_reader :type  # not set here, but it will be set by each piece
  attr_reader :rotation
  attr_reader :possible_offsets
  attr_reader :jumps_to_target

  def initialize(game, owner)
    @game     = game
    @owner    = owner

    @position = [-1,-1]
    @possible_offsets = []
    @jumps_to_target = false # kings and pawns can only move one tile at a time

    # @possible_offsets below is written using the "bottom" pieces as reference.
    #   so, when moving top pieces, we need to rotate the coordinates by 180
    #   degrees by multiplying both axes by -1.
    @rotation = owner.home_base == :top ? -1 : 1

  end

  def add_to_board_at(pos_arr)
    @game.board.add_piece self, pos_arr
    pos_x, pos_y = pos_arr
    @position = [pos_x, pos_y]
  end

  # def possible_moves
  # # - calculates all the possible target positions based on the piece's current
  # #     position
  # #
  # # - this filters out values less than 1, for obvious reasons, but it will not
  # #     filter out other coordinates that may be off the board. this should be
  # #     the board's responsibility since it knows things like how big it is,
  # #     as well as what other pieces may be in the way
  #   current_position = position
  #   all_possible_moves = []
  #
  #   @possible_offsets.each do |pos|
  #     target_pos = coord_add(current_position, pos)
  #
  #     if target_pos[0] > 0 && target_pos[1] > 0
  #       all_possible_moves << target_pos
  #     end
  #   end
  #
  #   all_possible_moves
  # end


end # class
