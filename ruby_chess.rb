lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib)
require 'rubygems'
require 'bundler/setup'
require 'colorize'
require 'byebug'

require 'game_controller'
require 'cli_display'

# this is the heart of the chess game. this loop will run over and over
#   until the user exits. it updates the screen, prompts the user based
#   on the current state of the game, and waits for input.
def main_loop
  @game         = GameController.new
  @display      = CliDisplay.new(board: @game.board_state)
  @input_state  = :select_piece # select_piece
  @flash        = [] # for error messages, etc

  while true
    @display.update(@game.board_state)
    prompt_for @input_state
    input = gets.chomp
    parse input
    # TODO: we have a game_over method here we can call when ready...
  end # while true
end

private

def prompt_for(state)
  # this determines what to display in each circumstance.
  if @flash
    @flash.uniq.each { |msg| puts msg.colorize(color: :blue) }
    @flash = []
  end
  puts " "
  prompt = "(#{@game.current_player[:name]}, #{@game.current_player[:home_base]})"

  case state
  when :select_piece
    string = "#{prompt} Select a piece (e.g. a1)"
  when :move_piece
    string = "#{prompt} Select a highlighted tile (or '" + "c".underline + "ancel')"
  when :game_won
    exit
  end
  print string + " > "

end

def parse(cmd)
  # takes the user's string and decides what to do with it.
  case cmd
  when "exit", "x", "q"; exit
  when "cancel", "c"; process_command cmd
  when "byebug"; byebug
  when cmd[/^[a^-hA-H][1-8]$/]
    # matches two-character commands beginning with a letter
    #   and ending with a number.
    process_command cmd
  else
    @flash.push FLASH_MESSAGES[:invalid_selection]
    select_piece @cur_piece if @cur_piece
  end

end

def process_command(cmd)
  case @input_state
  when :select_piece
    begin
      cur_possible_moves = @game.select_piece(cmd)
      cur_possible_moves.each do |coord, move_type|
        @display.paint_square coord, move_type, :high_priority
      end
      @input_state = :move_piece
    rescue Game::InvalidSelectionError
      #
    end

  when :move_piece
    if cmd == "cancel"
      @input_state = :select_piece
    else
      @game.move_piece(cmd)
      @display.reset_display
      @input_state = :select_piece
    end
  end
end

main_loop
