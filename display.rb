class Display
  # guess what - display will handle the graphics!

  def initialize(board:)
    # pass Display a board object so it can read it
    @board = board
  end

  def update
    # even though this is the whole board, it's best to think of it as
    #   'row' because we're iterating through each row, working on column
    #   values one by one.
    row = @board.pieces
    byebug
    row.each do |col|
      col.each do |piece|
        print " [#{piece.type}] "
      end
    end

  end
end
