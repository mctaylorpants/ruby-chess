class Board
  attr_reader :pieces

  def initialize
    build_board

  end

  def add_piece(piece, pos_x, pos_y)
    # because the array is zero-based, but we want to express the positions as
    #  starting from 1, we have to subtract one to the coordinates before we
    #  can access the correct element in the array.
    pieces[array_pos_for pos_x][array_pos_for pos_y] = piece
  end

  def piece_at(pos_x, pos_y)
    # returns the piece at this position, or nil if it's empty.
    pieces[array_pos_for pos_x][array_pos_for pos_y]
  end

  private
  def build_board
    # - our board is a multi-dimensional array where each outer element is a
    #     row (x), and each inner element is a column (y).
    # - the objects are stored in the columns, but we set them to nil
    #     until we add pieces
    @pieces =
              [
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil],
                [nil, nil, nil, nil, nil, nil, nil, nil],
              ]
  end

  def array_pos_for(i)
    # offsets the coordinate position to return the correct element in the array.
    i - 1
  end

end
