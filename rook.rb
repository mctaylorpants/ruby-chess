require "./piece.rb"

class Rook < Piece

  def initialize(game, owner)
    super
    @type = :rook

    # each array within possible_offsets is an x,y offset from the current
    #  position of the piece. the resulting target coordinates will be
    #  validated by the board to make sure it wouldn't be off the board.
    @possible_offsets = [
                          [1,0],
                          [0,-1],
                          [-1,0],
                          [0,1]
                        ]

    # only the left rook can move [3,0] and only the right rook can move [-2,0]
    @special_moves = { :castling => [[3,0],[-2,0]] }
  end

end
