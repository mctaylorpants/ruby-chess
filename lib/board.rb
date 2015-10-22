class Board
  attr_reader :board

  def initialize
    build_board
  end

  private
  def build_board
    # - our board is a multi-dimensional array where each outer element is a
    #     row (x), and each inner element is a column (y).
    # - the objects are stored in the columns, but we set them to nil
    #     until we add pieces
    col = [nil, nil, nil, nil, nil, nil, nil, nil]

    @board =
      [
        col,
        col,
        col,
        col,
        col,
        col,
        col,
        col,
      ]
  end

end
