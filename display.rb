require "colorize"
require "./chess_helpers"
# TODO: what's the best way to smartly require all these and have them be path-dependnet?

# colorize examples:
# puts "This is blue".colorize(:blue)
# puts "This is light blue".colorize(:light_blue)
# puts "This is also blue".colorize(:color => :blue)
# puts "This is light blue with red background".colorize(:color => :light_blue, :background => :red)
# puts "This is light blue with red background".colorize(:light_blue ).colorize( :background => :red)
# puts "This is blue text on red".blue.on_red
# puts "This is red on blue".colorize(:red).on_blue
# puts "This is red on blue and underline".colorize(:red).on_blue.underline
# puts "This is blue text on red".blue.on_red.blink
# puts "This is uncolorized".blue.on_red.uncolorize

class Display
  # guess what - display will handle the graphics!
  include ChessHelpers

  # TODO: Display::Buffer.new_buffer to init the arrays below [ [],[],[],[],[],[],[],[] ]

  def initialize(board:)
    # pass Display a board object so it can read it
    @buffer = []
    @board = board
    @buf_low_priority  = Buffer.new_buffer # this will get passed in from game
    @buf_high_priority = Buffer.new_buffer # for adding highlights and possible moves to the buffer
  end

  def update(buffer)
    fill_low_priority_buffer buffer
    buffer_fill
    buffer_print
  end

  def highlight_square(coord_arr, move_type, target_buffer)
    # changes the background and text of the square, but will
    #   not remove an icon if one exists for it already.
    piece = @board.piece_at(coord_arr)
    move_type = piece.type == :nil_piece ? :dot_square : move_type
    paint_square(coord_arr, move_type, target_buffer, :bg_safe_move)
  end

  def paint_square(coord_arr, move_type, target_buffer, background=nil)
    # replaces the contents of a square
    sep = " "
    x = array_pos_for coord_arr[0]
    y = array_pos_for coord_arr[1]
    # y and x are intentionally reversed!
    case target_buffer
    when :low_priority
      @buf_low_priority[y][x] = icon_for(move_type, background)
    when :high_priority
      @buf_high_priority[y][x] = icon_for(move_type, background)
    end
  end

  def reset_display
    # clears the two buffers
    @buf_low_priority = Buffer.new_buffer
    @buf_high_priority = Buffer.new_buffer
  end

  private
  def icon_for(piece_type, background=nil)
    # serves up a string icon for each piece.
    sep = " "
    case background
    when :top;          bgcolor = :red
    when :bottom;       bgcolor = :blue
    when :bg_safe_move;           bgcolor = :light_yellow
    else;                         bgcolor = :light_white
    end

    # TODO: dot_square, poss_move are the same
    case piece_type
    when :nil_piece;      icon = "   ".colorize(background: bgcolor).underline
    when :rook;           icon = " \u2656 ".colorize(color: :white, background: bgcolor).underline
    when :knight;         icon = " \u2658 ".colorize(color: :white, background: bgcolor).underline
    when :bishop;         icon = " \u2657 ".colorize(color: :white, background: bgcolor).underline
    when :king;           icon = " \u2654 ".colorize(color: :white, background: bgcolor).underline
    when :queen;          icon = " \u2655 ".colorize(color: :white, background: bgcolor).underline
    when :pawn;           icon = " \u2659 ".colorize(color: :white, background: bgcolor).underline
    when :poss_move;      icon = " • ".colorize(color: :white, background: :light_magenta).blink
    when :capture_piece;  icon = " \u2620 ".colorize(color: :white, background: :light_red).blink
    when :dot_square;     icon = " • ".colorize(color: :black, background: bgcolor)
    when :win_square;     icon = " \u1F604 ".colorize(color: :white, background: :green).blink
    end # case

    node = "#{icon}#{sep}"
  end

  def fill_low_priority_buffer(buffer)
    if buffer
      buffer.each do |coord, move_type|
        paint_square coord, move_type, :low_priority
      end
    end
  end

  def buffer_fill
    # even though this is the whole board, it's best to think of it as
    #   'row' because we're iterating through each row, working on column
    #   values one by one.

    @buffer = @board.pieces.map do |row|
      r = []
      row.each do |piece|
          r << icon_for(piece.type, piece.owner.home_base)
      end

      r # TODO: shouldn't this be at the bottom???
    end # end @buffer=

    if @buf_low_priority
      # merge the contents of @buf_low_priority into the buffer
      # this will be overwritten by any high-priority
      # elements (like possible moves)
      @buf_low_priority.each_with_index do |outer_element, outer_index|
        outer_element.each_with_index do |inner_element, inner_index|
          @buffer[outer_index][inner_index] = inner_element unless !inner_element
        end
      end
    end

    if @buf_high_priority.any?
      # merge the contents of @buf_high_priority into the buffer
      @buf_high_priority.each_with_index do |outer_element, outer_index|
        outer_element.each_with_index do |inner_element, inner_index|
          @buffer[outer_index][inner_index] = inner_element unless !inner_element
        end
      end

      @buf_high_priority = Buffer.new_buffer
    end


  end

  def buffer_print
    system "clear" # clears the screen
    # prints the current buffer to the screen
    puts "•  a   b   c   d   e   f   g   h   •".colorize(color: :green)
    puts " "

    @buffer.reverse.each_with_index do |line, index|
      index_colored = "#{8 - index}".colorize(color: :green)
      puts "#{index_colored} #{line.join("")} #{index_colored}"
      puts ""
    end

    puts "•  a   b   c   d   e   f   g   h   •".colorize(color: :green)

  end

  class Buffer
    def self.new_buffer
      [ [],[],[],[],[],[],[],[] ] # returns a multi-d array in the shape of the board
    end
  end
end
