require "./piece.rb"

class Bishop < Piece

  def initialize(game, owner)
    super
    @type = :bishop

    # each array within possible_offsets is an x,y offset from the current
    #  position of the piece. the resulting target coordinates will be
    #  validated by the board to make sure it wouldn't be off the board.
    @possible_offsets = [
                          [1,1],
                          [1,-1],
                          [-1,-1],
                          [-1,1]
                        ]
  end

end
