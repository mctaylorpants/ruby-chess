require "byebug" # for debugging purposes
require "colorize"

require "./chess_helpers.rb"
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
  include ChessHelpers

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

  FLASH_MESSAGES = {
    :invalid_selection => "Invalid selection!",
    :invalid_move => "Invalid move! Try again.",
    :captured_piece => "You captured <PLAYER>'s <PIECE>!"
  }

  BOARD_MAX_COORD_X = 8
  BOARD_MAX_COORD_Y = 8

  def initialize
    @board      = Board.new
    @display    = Display.new board: @board
    @player1    = Player.new "Player 1", :bottom
    @player2    = Player.new "Player 2", :top
    @state      = GAME_STATES[0] # select_piece
    @flash      = "" # for error messages, etc
    @cur_player = @player1
    @cur_piece  = nil # once a player selects a piece, this stores it
    @cur_possible_moves = nil # stores hash of the moves available to
                              #    the currently-selected piece
    add_pieces
    main_loop
  end



  private
  def main_loop
    # this is the heart of the chess game. this loop will run over and over
    #   until the user exits. it updates the screen, prompts the user based
    #   on the current state of the game, and waits for input.
    while true
      display.update
      prompt_for @state
      input = gets.chomp
      parse input
    end # while true
  end

  def prompt_for(state)
    # this determines what to display in each circumstance.
    puts @flash.colorize(color: :blue) if @flash
    puts " "

    case state
    when :select_piece
      string = "(#{@cur_player.name} #{@cur_player.home_base}) Select a piece (e.g. a1)"
    when :move_piece
      string = "(#{@cur_player.name} #{@cur_player.home_base}) Select a highlighted tile (or type 'cancel')"
    end
    print string + " > "

    @flash = ""

  end

  def parse(cmd)
    # takes the user's string and decides what to do with it.
    case cmd
    when "exit", "x", "q"
      exit
    when "cancel"
      process_command cmd
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
      if cmd == "cancel"
        @state = :select_piece
      else
        move_piece_to(pos_for_coord(cmd))
      end
    end
  end

  def select_piece(piece)
    if piece.owner == @cur_player
      @state = :move_piece
      @cur_piece = piece
      @cur_possible_moves = possible_moves_for @cur_piece
      @cur_possible_moves.each do |coord, move_type|
        display.paint_square coord, move_type
      end
    else
      @flash = FLASH_MESSAGES[:invalid_selection]
    end
  end

  def move_piece_to(coord)
    if @cur_piece && move_is_valid?(coord)
       byebug
      check_for_captured_piece_at(coord)
      board.move_piece(@cur_piece, coord)
      toggle_player
    else
      @flash = FLASH_MESSAGES[:invalid_move]
      select_piece @cur_piece
    end
  end

  def check_for_captured_piece_at(coord)
    piece = board.piece_at(coord)
    if piece.owner == other_player
      @flash = FLASH_MESSAGES[:captured_piece].\
          gsub("<PLAYER>",piece.owner.name).\
          gsub("<PIECE>",piece.type.to_s)
    end
  end

  def move_is_valid?(proposed_move)
    @cur_possible_moves.keys.include? proposed_move
  end

  def toggle_player
    @cur_player.increment_move_count
    @cur_player = other_player
    @state = :select_piece
  end

  def possible_moves_for(this_piece)
    # given a piece, returns a new array containing all the
    #   valid moves on the board, and the result that each move would have
    #   (e.g. 'move', 'kill', 'check', 'checkmate'.) the result is used to
    #   show the player what that move would do.
    #

    # first, we generate all the physically possible moves on the board and
    #   store them in legal_moves. however, we haven't added special moves
    #   for pieces like pawns and kings, and we haven't removed moves that
    #   would result in checkmate.
    legal_moves = generate_moves_along_path(this_piece)
    legal_moves = filter_special_moves this_piece, legal_moves

    legal_moves
  end

  def generate_moves_along_path(this_piece)
    # for each move, walk the path between the current position
    #   and the target position. return when we hit another piece
    #   or the edge of the board
    legal_moves = {}

    this_piece.possible_offsets.each do |offset|
      this_pos = this_piece.position

      while true
        potential_position = coord_add(this_pos, offset)
        break unless is_a_legal_move?(this_piece, potential_position)

        if board.piece_at(potential_position).owner == other_player
          legal_moves[potential_position] = :capture_piece
          break
        else
          legal_moves[potential_position] = :poss_move
          break if this_piece.jumps_to_target
        end

        this_pos = potential_position
      end # while true
    end # possible_offsets

    legal_moves
  end

  def is_a_legal_move?(piece, coord_arr)
    coord_arr[0] <= BOARD_MAX_COORD_X &&
    coord_arr[1] <= BOARD_MAX_COORD_Y &&
    coord_arr[0] > 0 &&
    coord_arr[1] > 0 &&
    piece.owner != board.piece_at(coord_arr).owner
  end

  def filter_special_moves(piece, legal_moves)
    # with an array of moves and a piece, remove or add special moves that
    #   the piece has. returns an array.

    # TODO: all the game logic is going here. is there a better place we can
    #   store this?
    array_of_moves = legal_moves.dup

    case piece.type
    when :pawn
      # pawn - opening move
      if @cur_player.num_moves == 0
        opening_move = coord_add(piece.position, piece.special_moves(:opening_move))
        array_of_moves[opening_move] = :poss_move
      end

      # pawn - diagonal capture
      # TODO

    end

    array_of_moves
  end

  def other_player
    @cur_player == @player1 ? @player2 : @player1
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
    (Queen.new(self, player)).add_to_board_at   [4,1]
    (King.new(self, player)).add_to_board_at    [5,1]
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
    (Queen.new(self, player)).add_to_board_at   [4,8]
    (King.new(self, player)).add_to_board_at    [5,8]
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
