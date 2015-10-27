require "byebug" # for debugging purposes
require "colorize"

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

  # using this plus the @cur_player variable, we determine what state the
  #   game is in and how it should respond to commands.
  GAME_STATES = [:select_piece,
                :move_piece]

  # this is used to convert chess coordinates (e.g. a4) to standard x,y coords
  NUMBER_FOR_LETTER = { "a" => 1,
                        "b" => 2,
                        "c" => 3,
                        "d" => 4,
                        "e" => 5,
                        "f" => 6,
                        "g" => 7,
                        "h" => 8 }

  BOARD_MAX_COORD_X = 8
  BOARD_MAX_COORD_Y = 8

  def initialize
    @board      = Board.new
    @display    = Display.new board: @board
    @player1    = Player.new "Player 1", :bottom
    @player2    = Player.new "Player 2", :top
    @state      = GAME_STATES[0] # select_piece
    @cur_player = @player1
    @cur_piece  = nil # once a player selects a piece, this stores it
    @cur_possible_moves = nil # stores an array of the moves available to
                              #    the currently-selected piece
    add_pieces
    main_loop
  end



  private
  def main_loop
    # this will control the graphics, player input, etc.
    while true
      display.update
      prompt_for @state
      input = gets.chomp
      parse input
    end # while true
  end

  def prompt_for(state)
    # this determines what to display in each circumstance.
    case state
    when :select_piece
      string = "(#{@cur_player.name} #{@cur_player.home_base}) Select a piece (e.g. d2)"
    when :move_piece
      string = "(#{@cur_player.name} #{@cur_player.home_base}) Select a highlighted tile"
    end
    print string + " > "

  end

  def parse(cmd)
    # takes the user's string and decides what to do with it.
    case cmd
    when "exit", "x"
      exit
    when cmd[/^[a^-zA-Z][0-9]$/]
      # matches two-character commands beginning with a letter
      #   and ending with a number.
      process_command cmd
    end

  end

  def process_command(cmd)
    case @state
    when :select_piece
      select_piece board.piece_at(pos_for_coord(cmd))
    when :move_piece
      move_piece_to(pos_for_coord(cmd))
    end

  end

  def select_piece(piece)
    if piece.owner == @cur_player
      @state = :move_piece
      @cur_piece = piece
      @cur_possible_moves = possible_moves_for(piece)
      @cur_possible_moves.each do |coord|
        display.paint_square coord, :possible_move_square
      end
    end
  end

  def move_piece_to(coord)
    if @cur_piece && move_is_legal?(coord)
      board.move_piece(@cur_piece, coord)
      toggle_player
    else
      select_piece @cur_piece
    end
  end

  def move_is_legal?(proposed_move)
    @cur_possible_moves.include? proposed_move
  end

  def toggle_player
    if @cur_player == @player1
      @cur_player = @player2
    else
      @cur_player = @player1
    end

    @state = :select_piece
  end

  def possible_moves_for(this_piece)
    # given a piece, returns a new array containing all the
    #   valid moves on the board, and the result that each move would have
    #   (e.g. 'move', 'kill', 'check', 'checkmate'.) the result is used to
    #   show the player what that move would do.
    #
    # this method removes moves that would:
    #   - go off the board
    #   - collide with another piece owned by the player
    #   - allow checkmate

    legal_moves = this_piece.possible_moves.select do |move_pos|
      move_pos[0] <= BOARD_MAX_COORD_X &&
      move_pos[1] <= BOARD_MAX_COORD_Y &&
      this_piece.owner != board.piece_at(move_pos).owner
    end
  end


  def pos_for_coord(coord_string)
    # converts a board coordinate (e.g. a4) into a proper coordinate
    x = NUMBER_FOR_LETTER[coord_string[0]]
    y = coord_string[1].to_i
    [x, y]
  end

  def add_pieces
    # builds each piece for each player and puts it on the board.
    # TODO: use metaprogramming to automatically instantiate the objects
    # TODO: god there's definitely a sexier way to do this...

    # add player 1 (bottom) pieces
    player = @player1
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

    # add player 2 (top) pieces
    player = @player2
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
  end


end
