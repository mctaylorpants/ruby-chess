lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib)
require 'rubygems'
require 'bundler/setup'
require 'colorize'
require 'byebug'

require 'game_controller'
require 'cli_display'

FLASH_MESSAGES = {
  :invalid_selection =>    "Invalid selection!",
  :no_moves_available =>   "No moves available for that piece",
  :player_is_in_check =>   "<PLAYER>, you are in check! Your moves are limited.",
  :invalid_move =>         "Invalid move! Try again.",
  :invalid_move_check =>   "No moves available for that piece - protect your king!",
  :captured_piece =>       "You captured a <PIECE>!",
  :castling =>             "(You may castle to <POS>)",
  :game_over =>            "CHECKMATE – <PLAYER> is victorious! Congratulations!"
}

# this is the heart of the chess game. this loop will run over and over
#   until the user exits. it updates the screen, prompts the user based
#   on the current state of the game, and waits for input.
def main_loop
  @game         = GameController.new
  @display      = CliDisplay.new(board: @game.board_state)
  @input_state  = :select_piece # select_piece
  @active_tile  = nil

  while true
    @display.update(@game.board_state)
    exit if @game.state == :checkmate
    prompt_for @input_state
    input = gets.chomp
    parse input
  end # while true
end

private

def prompt_for(state)
  # this determines what to display in each circumstance.
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
    @display.flash.push FLASH_MESSAGES[:invalid_selection]
    select_piece @cur_piece if @cur_piece
  end

end

def process_command(cmd)
  case @input_state
  when :select_piece; select_piece(cmd)
  when :move_piece; move_piece(cmd)
  end
end

def select_piece(cmd)
  begin
    cur_possible_moves = @game.select_piece(cmd)
    if cur_possible_moves.any?
      cur_possible_moves.each do |coord, move_type|
        @display.paint_square coord, move_type, :high_priority
      end
      @active_tile = cmd
      @input_state = :move_piece

    else
      @display.flash.push FLASH_MESSAGES[:no_moves_available]
      @input_state = :select_piece
    end

  rescue Game::InvalidSelectionError
    @display.flash.push FLASH_MESSAGES[:invalid_selection]
  end
end

def move_piece(cmd)
  return if cmd == "cancel"
  result = @game.move_piece(cmd)

  if result[:captured_piece]
    @display.flash.push FLASH_MESSAGES[:captured_piece].gsub("<PIECE>", result[:captured_piece].to_s)
  end

  case result[:state]
  when :success
    @display.reset_display

  when :invalid_move
    @display.flash.push FLASH_MESSAGES[:invalid_move]
    return select_piece(@active_tile)

  when :invalid_move_check
    @display.flash.push FLASH_MESSAGES[:invalid_move_check]
    return select_piece(@active_tile)

  when :check
    @display.reset_display
    @display.flash.push FLASH_MESSAGES[:player_is_in_check].gsub("<PLAYER>",@game.current_player[:name])

  when :checkmate
    @display.reset_display
    @display.flash.push FLASH_MESSAGES[:game_over].gsub("<PLAYER>",@game.current_player[:name])
    # yaaaay!
    (1..8).each do |x|
      (1..8).each do |y|
        @display.paint_square [x,y], :win_square, :high_priority
      end
    end
  else
    raise
  end

  @input_state = :select_piece
end

main_loop
