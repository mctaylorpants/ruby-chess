require "colorize"
require "./chess_helpers"

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

  def initialize(board:)
    # pass Display a board object so it can read it
    @buffer = []
    @board = board
    @buf_replace = [ [],[],[],[],[],[],[],[] ] # for adding highlights and possible moves to the buffer
  end

  def update
    buffer_fill
    buffer_print
  end

  def highlight_square(coord)
    # highlights a specific square
  end

  def paint_square(coord_arr, move_type)
    # replaces the contents of a square
    sep = " "
    x = array_pos_for coord_arr[0]
    y = array_pos_for coord_arr[1]
    # y and x are intentionally reversed!
    @buf_replace[y][x] = icon_for(move_type)
  end

  private
  def icon_for(piece_type, home_base=nil)
    # serves up a string icon for each piece.
    sep = " "
    if home_base == :top
      team_colour = :red
    elsif home_base == :bottom
      team_colour = :blue
    else
      team_colour = :light_white
    end

    case piece_type
    when nil;             icon = "   ".colorize(background: team_colour).underline
    when :rook;           icon = " # ".colorize(color: :white, background: team_colour).underline
    when :knight;         icon = " & ".colorize(color: :white, background: team_colour).underline
    when :bishop;         icon = " ! ".colorize(color: :white, background: team_colour).underline
    when :king;           icon = " + ".colorize(color: :white, background: team_colour).underline
    when :queen;          icon = " * ".colorize(color: :white, background: team_colour).underline
    when :pawn;           icon = " - ".colorize(color: :white, background: team_colour).underline
    when :poss_move;      icon = " • ".colorize(color: :white, background: :light_magenta).blink
    when :capture_piece;  icon = " X ".colorize(color: :white, background: :light_red).blink
    end # case

    node = "#{icon}#{sep}"
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

      r
    end # end @buffer=
    if @buf_replace.any?
      # merge the contents of @buf_replace into the buffer
      @buf_replace.each_with_index do |outer_element, outer_index|
        outer_element.each_with_index do |inner_element, inner_index|
          @buffer[outer_index][inner_index] = inner_element unless !inner_element
        end
      end

      @buf_replace = [ [],[],[],[],[],[],[],[] ]
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
end
