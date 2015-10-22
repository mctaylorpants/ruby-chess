require "./piece.rb"

class Knight < Piece

  def initialize(game)
    super

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

  def possible_moves
    # - calculates all the possible target positions on the board
    #     based on the piece's current position
    # - communicates with the board to eliminate invalid moves
    current_position = position
    all_possible_moves = []

    @possible_offsets.each do |pos|
      target_pos = coord_add(current_position, pos)
      all_possible_moves << target_pos
    end

    all_possible_moves
  end



end
