require "./piece.rb"

class Pawn < Piece

  def initialize(game, owner)
    super
    @type = :pawn
    @jumps_to_target = true

    # each array within possible_offsets is an x,y offset from the current
    #  position of the piece. the resulting target coordinates will be
    #  validated by the board to make sure it wouldn't be off the board.
    @possible_offsets = [
                          [0, 1 * @rotation]
                        ]

    @special_moves = { :opening_move => [0, 2 * @rotation],
                       :diagonal_capture => [[1,1],
                                             [1,-1],
                                             [-1,-1],
                                             [-1,1]]}
  end

end
