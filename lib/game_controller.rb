require 'game'

class GameController
  attr_reader :board

  def initialize
    @game = Game.new
    @board = @game.board
  end

  # Returns a nested array of the current board state.
  #
  # Each row represents the 'y' axis. The index of each element within a
  # row represents the 'x' axis.
  #
  # Each element is a hash containing the home base and the piece type.
  # Example: { player: :bottom, piece: :rook}
  def board_state
    @game.board_state.map do |row|
      row.map do |piece|
        { player: piece.owner.home_base,
          piece:  piece.type }
      end
    end
  end

  # Returns a symbol describing the current state of the game. One of:
  # :in_progress
  # :check
  # :checkmate
  def state
    @game.state
  end

  # Returns :bottom or :top, depending on who the current player is.
  def current_player
    { name: @game.cur_player.name, home_base: @game.cur_player.home_base }
  end

  # Selects a piece based on the notational coordinate and returns an array
  # of possible moves for that piece, if any.
  #
  # Example: select_piece('c2')
  def select_piece(coord)
    begin
      @game.select_piece_at(coord)
    rescue
      raise
    end
  end

  # Returns a hash of possible moves, or an empty hash if there are none
  # Each key of the hash is an array representing a board coordinate. The
  # value is one of the following symbols:
  # :poss_move
  # :capture_piece
  #
  # Example: {[3, 3]=>:poss_move, [3, 4]=>:poss_move}
  def possible_moves
    @game.cur_possible_moves
  end

  # Returns the piece at the specified location.
  # Example:
  # { player: :bottom, type: :pawn }
  def piece_at(coord)
    @game.piece_at(coord)
  end

  # With a currently selected piece, moves that piece to the specified
  # notational coordinate. Returns a status hash.
  def move_piece(coord)
    @game.move_piece_to(coord)
  end
end
