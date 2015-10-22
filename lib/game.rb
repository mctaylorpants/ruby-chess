require "byebug" # for debugging purposes

require "./board.rb"
require "./knight.rb"

class Game
  # game objects
  attr_reader :board
  attr_reader :p1_knight_1 # TODO: refactor all pieces into an array or something

  def initialize
    @board = Board.new
    add_pieces
  end

  private
  def add_pieces
    # builds each piece for each player and puts it on the board.
    @p1_knight_1 = Knight.new(self)

    # even though we could access this with @board, we access it using
    #  the attr_reader (above). this is best-practice since if we ever
    #  need to change the behaviour of board, we can write a specific
    #  'board' method for it and all of our calls will still work.
    p1_knight_1.add_to_board_at 1,1

  end


end
