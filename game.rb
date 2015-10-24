require "byebug" # for debugging purposes

require "./board.rb"
require "./display.rb"
require "./player.rb"
require "./pawn.rb"
require "./rook.rb"
require "./knight.rb"
require "./bishop.rb"
require "./king.rb"
require "./queen.rb"

class Game
  # game objects
  attr_reader :board
  attr_reader :display
  attr_reader :state # this will hold the game's "state". is it player 1's turn?
                     #   has the player selected a piece? etc

  def initialize
    @board = Board.new
    @display = Display.new board: @board
    @player1 = Player.new "Player 1", :bottom
    @player2 = Player.new "Player 2", :top
    @state   = :player_1_turn
    add_pieces

    main_loop
  end

  private
  def main_loop
    # this will control the graphics, player input, etc.
    while true
      @display.update
      prompt_for @state
      input = gets.chomp
      process_command input
    end # while true
  end

  def prompt_for(state)
    # this determines what to display in each circumstance.
    case state
    when :player_1_turn
      string = "(Player 1 bottom) Select a piece (e.g. a4)"
    end

    print string + " > "
  end

  def process_command(x)
    # takes the user's string and decides what to do with it.
    case x
    when "exit", "x"
      exit
    when x[/^[a^-zA-Z][0-9]$/]
      # matches two-character commands beginning with a letter
      #   and ending with a number.
      @state == :player_1_turn ? :player_2_turn : :player_1_turn
      raise @state
    end

  end

  def add_pieces
    # builds each piece for each player and puts it on the board.
    # TODO: use metaprogramming to automatically instantiate the objects
    # TODO: god there's definitely a sexier way to do this...

    # add player 1 (top) pieces
    player = @player1
    (Rook.new(self, player)).add_to_board_at    [1,8]
    (Knight.new(self, player)).add_to_board_at  [2,8]
    (Bishop.new(self, player)).add_to_board_at  [3,8]
    (King.new(self, player)).add_to_board_at    [4,8]
    (Queen.new(self, player)).add_to_board_at   [5,8]
    (Bishop.new(self, player)).add_to_board_at  [6,8]
    (Knight.new(self, player)).add_to_board_at  [7,8]
    (Rook.new(self, player)).add_to_board_at    [8,8]

    (Pawn.new(self, player)).add_to_board_at    [1,7]
    (Pawn.new(self, player)).add_to_board_at    [2,7]
    (Pawn.new(self, player)).add_to_board_at    [3,7]
    (Pawn.new(self, player)).add_to_board_at    [4,7]
    (Pawn.new(self, player)).add_to_board_at    [5,7]
    (Pawn.new(self, player)).add_to_board_at    [6,7]
    (Pawn.new(self, player)).add_to_board_at    [7,7]
    (Pawn.new(self, player)).add_to_board_at    [8,7]

    # add player 2 (bottom) pieces
    player = @player2
    (Rook.new(self, player)).add_to_board_at    [1,1]
    (Knight.new(self, player)).add_to_board_at  [2,1]
    (Bishop.new(self, player)).add_to_board_at  [3,1]
    (King.new(self, player)).add_to_board_at    [4,1]
    (Queen.new(self, player)).add_to_board_at   [5,1]
    (Bishop.new(self, player)).add_to_board_at  [6,1]
    (Knight.new(self, player)).add_to_board_at  [7,1]
    (Rook.new(self, player)).add_to_board_at    [8,1]

    (Pawn.new(self, player)).add_to_board_at    [1,2]
    (Pawn.new(self, player)).add_to_board_at    [2,2]
    (Pawn.new(self, player)).add_to_board_at    [3,2]
    (Pawn.new(self, player)).add_to_board_at    [4,2]
    (Pawn.new(self, player)).add_to_board_at    [5,2]
    (Pawn.new(self, player)).add_to_board_at    [6,2]
    (Pawn.new(self, player)).add_to_board_at    [7,2]
    (Pawn.new(self, player)).add_to_board_at    [8,2]
  end


end
