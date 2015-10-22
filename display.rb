class Display
  # guess what - display will handle the graphics!

  def initialize(board:)
    # pass Display a board object so it can read it
    @board = board
  end

  def update
    byebug
    arr = @board.pieces
  end
end
