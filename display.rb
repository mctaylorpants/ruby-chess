require "colorize"

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

  def initialize(board:)
    # pass Display a board object so it can read it
    @buffer = []
    @board = board
  end

  def update
    buffer_fill
    buffer_print
  end

  def icon_for(piece_type, home_base)
    # serves up a string icon for each piece.
    sep = " "
    if home_base == :top
      team_colour = :red
    elsif home_base == :bottom
      team_colour = :blue
    end

    case piece_type
    when nil;       icon = "   ".colorize(background: :light_white).underline
    when :rook;     icon = " # ".colorize(color: :white, background: team_colour).underline
    when :knight;   icon = " & ".colorize(color: :white, background: team_colour).underline
    when :bishop;   icon = " ! ".colorize(color: :white, background: team_colour).underline
    when :king;     icon = " + ".colorize(color: :white, background: team_colour).underline
    when :queen;    icon = " * ".colorize(color: :white, background: team_colour).underline
    when :pawn;     icon = " - ".colorize(color: :white, background: team_colour).underline
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

  end

  def buffer_print
    # prints the current buffer to the screen
    @buffer.reverse.each_with_index do |line, index|
      index_colored = "#{index + 1}".colorize(color: :green)
      puts "#{index_colored} #{line.join("")}"
      puts ""
    end

    puts " a   b   c   d   e   f   g   h ".colorize(color: :green)

  end
end
