# TODO: add “you selected piece x” to flash
# TODO: if the user enters an invalid move, the possible moves stop flashing
# TODO: implement checkmate properly. there are some bugs

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
  attr_reader :turn
  attr_reader :board
  attr_reader :display
  attr_reader :state # this will hold the game's "state". is it player 1's turn?
                     #   has the player selected a piece? etc
  attr_accessor :flash

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
    :invalid_selection =>    "Invalid selection!",
    :no_moves_available =>   "No moves available for that piece",
    :invalid_move =>         "Invalid move! Try again.",
    :invalid_move_check =>   "No moves available for that piece - protect your king!",
    :captured_piece =>       "You captured <PLAYER>'s <PIECE>!",
    :game_over =>            "<PLAYER> is victorious! Congratulations!"
  }

  BOARD_MAX_COORD_X = 8
  BOARD_MAX_COORD_Y = 8

  def initialize
    @turn               = 1 # number of turns that have elapsed; used for checking certain game logic
    @board              = Board.new
    @display            = Display.new board: @board
    @player1            = Player.new "Player 1", :bottom
    @player2            = Player.new "Player 2", :top
    @input_state        = :select_piece # select_piece
    @check_state        = false # is a player in check?
    @flash              = [] # for error messages, etc
    @cur_player         = @player1
    @cur_piece          = nil # once a player selects a piece, this stores it
    @cur_possible_moves = nil # stores hash of the moves available to
                              #    the currently-selected piece
    @safe_moves = nil # if a player is in check, this will display the possible moves
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
      prompt_for @input_state
      input = gets.chomp
      parse input
      # TODO: we have a game_over method here we can call when ready...
    end # while true
  end

  def prompt_for(state)
    # this determines what to display in each circumstance.
    if @flash
      @flash.each { |msg| puts msg.colorize(color: :blue) }
      @flash = []
    end
    puts " "
    prompt = "(#{@cur_player.name}, #{@cur_player.home_base})"

    case state
    when :select_piece
      string = "#{prompt} Select a piece (e.g. a1)"
    when :move_piece
      string = "#{prompt} Select a highlighted tile (or type 'cancel')"
    when :game_won
      exit
    end
    print string + " > "

  end

  def parse(cmd)
    # takes the user's string and decides what to do with it.
    case cmd
    when "exit", "x", "q"; exit
    when "cancel"; process_command cmd
    when "byebug"; byebug
    when cmd[/^[a^-zA-Z][0-9]$/]
      # matches two-character commands beginning with a letter
      #   and ending with a number.
      process_command cmd
    end

  end

  def process_command(cmd)
    case @input_state
    when :select_piece
      select_piece board.piece_at(pos_for_coord(cmd))
    when :move_piece
      if cmd == "cancel"
        @input_state = :select_piece
      else
        move_piece_to(pos_for_coord(cmd))
        @turn += 1
      end
    end
  end

  def select_piece(piece)
    if piece.owner == @cur_player
      @input_state = :move_piece
      @cur_piece = piece
      @cur_possible_moves = possible_moves_for @cur_piece

      if @check_state
        # if we're in check and the possible moves for the piece isn't in safe moves
        @cur_possible_moves = @cur_possible_moves.keep_if do |i|
          @safe_moves.keys.include?(i)
        end

        if @cur_possible_moves.empty?
          @flash.push FLASH_MESSAGES[:invalid_move_check]
          @input_state = :select_piece
          return
        end

      end


      if @cur_possible_moves.count == 0
        @flash.push FLASH_MESSAGES[:no_moves_available]
        @input_state = :select_piece
      else
        @cur_possible_moves.each do |coord, move_type|
          display.paint_square coord, move_type, :high_priority
        end
      end
    else
      @flash.push FLASH_MESSAGES[:invalid_selection]
    end
  end

  def move_piece_to(coord)
    if @cur_piece && move_is_valid?(coord)
      check_for_captured_piece_at(coord)
      board.move_piece(@cur_piece, coord)
      toggle_player

      if player_is_in_check?
        # display these safe moves to the player; these are now
        #   the only options they have, so their next move should
        #   also be checked against this array.
        @safe_moves = get_safe_moves

        if @safe_moves
          @flash.push "#{@cur_player.name}, you are in check! Your moves are limited."
          # @safe_moves.each do |coord, move_type|
          #   #display.paint_square coord, move_type, :low_priority
          #   display.highlight_square coord, move_type, :low_priority
          # end
        else
          game_over # !!
        end
      end
    else
      if player_is_in_check?
        @flash.push FLASH_MESSAGES[:invalid_move_check]
      else
        @flash.push FLASH_MESSAGES[:invalid_move]
      end
      select_piece @cur_piece
    end
  end

  def check_for_captured_piece_at(coord)
    piece = board.piece_at(coord)
    if piece.owner == other_player
      @flash.push FLASH_MESSAGES[:captured_piece].\
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
    display.reset_display # we remove any special squares here since those are
                          #   displayed for a specific player
    @input_state = :select_piece
  end

  def possible_moves_for(this_piece, test_for_check = { hypothetical_position: nil, generate_threat_vector: nil })
    # given a piece, returns a new array containing all the
    #   valid moves on the board, and the result that each move would have
    #   (e.g. 'move', 'kill', 'check', 'checkmate'.) the result is used to
    #   show the player what that move would do.
    #

    # first, we generate all the physically possible moves on the board and
    #   store them in legal_moves. however, we haven't added special moves
    #   for pieces like pawns and kings, and we haven't removed moves that
    #   would result in checkmate.
    legal_moves = generate_moves_along_path(this_piece, test_for_check)
    legal_moves = filter_special_moves this_piece, legal_moves

    legal_moves
  end

  def possible_moves_for_pieces(piece_arr, exclude: false)
    possible_moves = {}
    piece_arr.each do |piece|
      next if exclude && piece.type == exclude
      this_piece_moves = possible_moves_for piece
      if this_piece_moves.any?
        this_piece_moves.map { |k| possible_moves[k[0]] = k[1] }
      end
    end
    return possible_moves
  end

  def generate_moves_along_path(this_piece, test_for_check = { hypothetical_position: nil, generate_threat_vector: nil })
    # for each move, walk the path between the current position
    #   and the target position. return when we hit another piece
    #   or the edge of the board
    hypothetical_position ||= test_for_check[:hypothetical_position]
    generate_threat_vector ||= test_for_check[:generate_threat_vector]
    other_player_piece_type = generate_threat_vector ? :threat_piece : :capture_piece

    legal_moves = {}

    this_piece.possible_offsets.each do |offset|
      # use a hypothetical position if one was given to us (for the purposes
      #   of testing for check/checkmate)
      this_pos = hypothetical_position ? hypothetical_position : this_piece.position

      while true
        potential_position = coord_add(this_pos, offset)
        break unless is_a_legal_move?(this_piece, potential_position)

        if board.piece_at(potential_position).owner == other_player
          legal_moves[potential_position] = other_player_piece_type
          break
        else
          legal_moves[potential_position] = :poss_move
          break if this_piece.jumps_to_target && generate_threat_vector.nil?
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

    # REFACTOR: all the game logic is going here. is there a better place we can
    #   store this?
    array_of_moves = legal_moves.dup

    case piece.type
    when :pawn
      # pawn - remove forward capture
      array_of_moves = array_of_moves.reject do |move|
        array_of_moves[move] == :capture_piece
      end

      # pawn - opening move
      if piece.moves == 0
        opening_move = coord_add(piece.position, piece.special_moves(:opening_move))
        array_of_moves[opening_move] = :poss_move
      end

      # pawn - en passant
      # for en passant, the following conditions have to be met:
      #  1. an enemy pawn has just advanced two squares on the previous turn
      #  2. this pawn is directly adjacent to the enemy pawn
      # if these conditions are met, this pawn can capture the enemy pawn,
      # and will move diagonally to occupy the square immediately behind the
      # captured pawn.
      piece.special_moves(:en_passant).each do |move|
        move = coord_add(piece.position, move)
        next if move[0] == 0 or move[1] == 0 # REFACTOR-001
        enemy_piece = board.piece_at(move)
        if enemy_piece &&
        enemy_piece.type == :pawn &&
        enemy_piece.owner == other_player &&
        @turn - enemy_piece.executed_opening_move == 1
          array_of_moves[move] = :capture_piece
        end
      end

      # pawn - diagonal capture
      piece.special_moves(:diagonal_capture).each do |move|
        move = coord_add(piece.position, move)
        next if move[0] == 0 or move[1] == 0 # REFACTOR-001
        array_of_moves[move] = :capture_piece if board.piece_at(move) && board.piece_at(move).owner == other_player
      end

      # TODO pawn - promotion (should be implemented in another area)

    when :king
      # TODO king - castling

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

  def player_is_in_check?
    @cur_possible_moves = possible_moves_for @cur_piece
    @cur_possible_moves.keys.each do |coord|
      piece = board.piece_at coord

      if piece.type == :king && piece.owner != @cur_piece.owner
        @check_state = @cur_piece.owner
        return true
      end
    end

    @check_state = false
    #false
  end

  def get_safe_moves
    # FIXME: since we're merging all the safe moves, there's a situation in which
    #      the king has no legal moves, but another piece has a legal move
    #      which overlaps with the king's potential movement, allowing the
    #      king to move when it shouldn't be allowed to.
    # if a player is in check, return all the safe moves available that would
    #   would resolve check - if any!

    # get the threat vectors for the current player's king. current
    #   the 'current player' in this context is the one who is threatened.
    king_threat_vectors = possible_moves_for @cur_player.king,
                                             generate_threat_vector: true

    king_possible_moves = possible_moves_for @cur_player.king
    ally_possible_moves = possible_moves_for_pieces @cur_player.pieces, exclude: :king

    # model the threat vectors for each position the king could
    #   move to. is there a position in which it would be safe?
    king_legal_moves = {}
    king_possible_moves.keys.each do |poss_move|
      threat_vectors = possible_moves_for @cur_player.king,
                                          hypothetical_position: poss_move,
                                          generate_threat_vector: true
      unless threat_vectors.values.include?(:threat_piece)
        king_legal_moves[poss_move] = :dot_square
      end
    end

    # compare the all the possible moves for the player's pieces.
    #   could any of them make the king safe?
    #   NOTE: you could only get out of check with a piece if there's
    #   only one threat vector; otherwise, the king MUST move.
    ally_legal_moves = {}
    ally_possible_moves.keys.each do |poss_move|
      if king_threat_vectors.include?(poss_move)
        ally_legal_moves[poss_move] = :dot_square
      end
    end

    safe_moves = {}
    # now we have all the possible moves for the king, and all the
    #   possible moves for the allied pieces that could protect the
    #   king. next, we check how many threat vectors exist.
    #   if one threat vector exists, the king OR a piece can resolve
    #   check. if two or more threat vectors exist, only the king
    #   has the potential to escape.

    safe_moves.merge!(king_legal_moves)

    if king_threat_vectors.values.count(:threat_piece) == 1
      safe_moves.merge!(ally_legal_moves)
    end
    safe_moves
  end

  def game_over
    # we use other_player here because we've already toggled to the other
    #   (defeated) player after moving the winning player's piece

    # a quick move sequence for testing to get to checkmate quickly:
    #   c2 -> c4, d7 -> d6, d1 -> a4 (player 1 wins)
    @input_state = :game_won
    @flash.push FLASH_MESSAGES[:game_over].gsub("<PLAYER>", other_player.name)
    (1..BOARD_MAX_COORD_X).each do |x|
      (1..BOARD_MAX_COORD_Y).each do |y|
        display.paint_square [x,y], :win_square
      end
    end
  end

  def add_pieces
    # builds each piece for each player and puts it on the board.
    # REFACTOR: use metaprogramming to automatically instantiate the objects

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
