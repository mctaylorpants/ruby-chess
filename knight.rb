require "./piece.rb"

class Knight < Piece

  def initialize(game, owner)
    # TODO: when I pass it game, it's just passing a reference, right?
    super
    @type = :knight

    # each array within possible_offsets is an x,y offset from the current
    #  position of the piece. the resulting target coordinates will be
    #  validated by the board to make sure it wouldn't be off the board.
    @possible_offsets = [
                          [-2,1],
                          [-1,2],
                          [1,2],
                          [2,1],
                          [2,-1],
                          [1,-2],
                          [-1,-2],
                          [-2,-1]
                        ]
  end


end
