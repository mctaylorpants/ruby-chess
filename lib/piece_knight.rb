class Knight < Piece

  def initialize(position)
    super

    # each array within possible_moves is an x,y offset from the current
    #  position of the piece. the resulting target coordinates will be
    #  validated by the board to make sure it wouldn't be off the board.
    @possible_moves = [
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

  def get_possible_moves
    # - calculates all the possible target positions on the board
    #     based on the piece's current position
    # - communicates with the board to eliminate invalid moves
    # - should be called like: Game.knight4.get_possible_moves
  end



end
