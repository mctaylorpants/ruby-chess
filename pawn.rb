require "./piece.rb"
require "./queen.rb" # for promotional purposes :P
require "./chess_helpers.rb"

class Pawn < Piece
  include ChessHelpers

  attr_reader :executed_opening_move

  def initialize(game, owner)
    super
    @type = :pawn
    @jumps_to_target = true
    @promoted = false

    # if the pawn jumps two squares on its first move, this will be true;
    #  used to calculate en passant
    @executed_opening_move = -1

    # each array within possible_offsets is an x,y offset from the current
    #  position of the piece. the resulting target coordinates will be
    #  validated by the board to make sure it wouldn't be off the board.
    @possible_offsets = [
                          [0, 1 * @rotation]
                        ]

    @special_moves = { :opening_move => [0, 2 * @rotation],
                       :en_passant => [[1,0],[-1,0]],
                       :diagonal_capture => [[1,1 * @rotation],
                                             [-1,1 * @rotation]]}
  end

  def position=(pos)
    # this controls the state of the pawn; in order to model en passant, we
    #  need to know if the pawn just executed an opening move.
    # @executed_opening_move will only be true until the pawn moves again.
    old_pos = position
    offset = coord_subtract(old_pos, pos)
    super

    # set the opening move flag; this is used for en passant logic
    if offset[1].abs == 2 && !@executed_opening_move
      @executed_opening_move = @game.turn
    end

    # check for en passant, and advance the piece by a square if it just happened.
    if offset[0].abs == 1 && offset[1].abs == 0
      new_pos = coord_add(pos, [0, 1 * @rotation])
      @game.board.move_piece(self, new_pos, false) # false: don't increment moves for this pawn
      @position = new_pos
    end

    if deserves_a_promotion?(pos)
      transform_to(Queen)
      @promoted = true
      @game.flash.push "Your pawn was promoted!"
    end

  end

  def transform_to(klass)
    temp_piece = klass.new(@game, @owner)
    @type = temp_piece.type
    @possible_offsets = temp_piece.possible_offsets
    @jumps_to_target = temp_piece.jumps_to_target
  end

  def deserves_a_promotion?(pos)
    if self.owner.home_base == :top
      return true if pos[1] == 1
    elsif self.owner.home_base == :bottom
      return true if pos[1] == 8
    end
  end


end
