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

  def initialize
    @board = Board.new
    @display = Display.new board: @board
    @player1 = Player.new "Player 1"
    @player2 = Player.new "Player 2"
    add_pieces

    main_loop
  end

  private
  def main_loop
    # this will control the graphics, player input, etc.
    @display.update
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
