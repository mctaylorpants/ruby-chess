class Display
  # guess what - display will handle the graphics!

  def initialize(board:)
    # pass Display a board object so it can read it
    @buffer = []
    @board = board
  end

  def update
    buffer_fill
    buffer_print
  end

  def icon_for(piece_type)
    # serves up a string icon for each piece.
    case piece_type
      when nil;       "[    ]"
      when :rook;     "[ RR ]"
      when :knight;   "[ KN ]"
      when :bishop;   "[ BI ]"
      when :king;     "[ ++ ]"
      when :queen;    "[ QQ ]"
      when :pawn;     "[ pa ]"
    end # case

  end

  def buffer_fill
    # even though this is the whole board, it's best to think of it as
    #   'row' because we're iterating through each row, working on column
    #   values one by one.
    @buffer = @board.pieces.map do |row|
      r = []
      row.each do |piece|
        r << icon_for(piece.type)
      end

      r
    end # end @buffer=

  end

  def buffer_print
    # prints the current buffer to the screen
    @buffer.reverse.each do |line|
      puts line.join("")
    end
  end
end
