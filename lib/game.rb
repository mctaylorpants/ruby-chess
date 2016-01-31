# TODO: add “you selected piece x” to flash
# TODO: if the user enters an invalid move, the possible moves stop flashing
# TODO: implement checkmate properly. there are some bugs

require "chess_helpers"
require "board"
require "display"
require "player"
require "pawn"
require "rook"
require "knight"
require "bishop"
require "king"
require "queen"

class Game
  include ChessHelpers

  class InvalidSelectionError < ::StandardError; end

  # game objects
  attr_reader :turn
  attr_reader :board
  attr_reader :cur_player
  attr_reader :cur_possible_moves
  attr_reader :display
  attr_reader :state # this will hold the game's "state". is it player 1's turn?
                     #   has the player selected a piece? etc

  # TODO: can this be read only?
  attr_accessor :flash

  FLASH_MESSAGES = {
    :invalid_selection =>    "Invalid selection!",
    :no_moves_available =>   "No moves available for that piece",
    :player_is_in_check =>   "<PLAYER>, you are in check! Your moves are limited.",
    :invalid_move =>         "Invalid move! Try again.",
    :invalid_move_check =>   "No moves available for that piece - protect your king!",
    :captured_piece =>       "You captured <PLAYER>'s <PIECE>!",
    :castling =>             "(You may castle to <POS>)",
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
    @flash              = [] # for error messages, etc
    @cur_player         = @player1
    @cur_piece          = nil # once a player selects a piece, this stores it
    @cur_possible_moves = Hash.new # stores hash of the moves available to
                              #    the currently-selected piece
    @safe_moves         = nil # if a player is in check, this will display the possible moves
    @state              = :in_progress
    add_pieces
  end

  # this is the heart of the chess game. this loop will run over and over
  #   until the user exits. it updates the screen, prompts the user based
  #   on the current state of the game, and waits for input.
  def main_loop
    while true
      display.update
      prompt_for @input_state
      input = gets.chomp
      parse input
      # TODO: we have a game_over method here we can call when ready...
    end # while true
  end

  def board_state
    board.board_state
  end

  def move_piece_to(coord)
    @state = :in_progress
    success = true
    piece = @cur_piece
    coord = pos_for_coord(coord)
    if piece && move_is_valid?(coord)
      check_for_captured_piece_at(coord)
      board.move_piece(piece, coord)
      @turn += 1
      toggle_player

      if player_is_in_check?
        @state = :check
        # display these safe moves to the player; these are now
        #   the only options they have, so their next move should
        #   also be checked against this array.
        @safe_moves = get_safe_moves

        if @safe_moves.any?
          @flash.push FLASH_MESSAGES[:player_is_in_check]
        else
          @state = :checkmate
          game_over # !!
        end
      end

    else
      success = false
      if player_is_in_check?
        @flash.push FLASH_MESSAGES[:invalid_move_check]
      else
        @flash.push FLASH_MESSAGES[:invalid_move]
      end
      select_piece piece
    end

    success
  end

  def select_piece_at(coord)
    select_piece board.piece_at(pos_for_coord(coord))
  end

  def piece_at(coord)
    piece = board.piece_at(pos_for_coord(coord))
    { player: piece.owner.home_base, type: piece.type }
  end

  private

  def prompt_for(state)
    # this determines what to display in each circumstance.
    if @flash
      @flash.uniq.each { |msg| puts msg.colorize(color: :blue) }
      @flash = []
    end
    puts " "
    prompt = "(#{@cur_player.name}, #{@cur_player.home_base})"

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
      select_piece_at(cmd)
    when :move_piece
      if cmd == "cancel"
        @input_state = :select_piece
      else
        move_piece_to(pos_for_coord(cmd))
      end
    end
  end

  def select_piece(piece)
    if piece.owner == @cur_player
      @input_state = :move_piece
      @cur_piece = piece
      @cur_possible_moves = possible_moves_for @cur_piece
      @flash.push "#{@cur_piece.type.capitalize} #{coord_for_pos(@cur_piece.position)}"

      if @state == :check
        if piece.type == :king
          # if we're in check and the possible moves for the piece isn't in safe moves
          @cur_possible_moves = @cur_possible_moves.keep_if do |i|
            @safe_moves[:king] && @safe_moves[:king].keys.include?(i)
          end
        else
          # if we're in check and the possible moves for the piece isn't in safe moves
          @cur_possible_moves = @cur_possible_moves.keep_if do |i|
            @safe_moves[:allies] && @safe_moves[:allies].keys.include?(i)
          end
        end

        if @cur_possible_moves.empty?
          @flash.push FLASH_MESSAGES[:invalid_move_check]
          @input_state = :select_piece
        end
      end

      # non-check
      if @cur_possible_moves.empty?
        @flash.push FLASH_MESSAGES[:no_moves_available]
        @input_state = :select_piece
      else
        @cur_possible_moves.each do |coord, move_type|
          display.paint_square coord, move_type, :high_priority
        end
      end
    else
      @flash.push FLASH_MESSAGES[:invalid_selection]
      raise InvalidSelectionError
    end

    @cur_possible_moves
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
        if board.piece_at(opening_move).type == :nil_piece &&
           board.piece_at(legal_moves.first[0]).type == :nil_piece
          array_of_moves[opening_move] = :poss_move
        end
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

    when :king
      # king - castling
      castling_moves = get_castling_moves(piece)
      array_of_moves.merge!(castling_moves) if castling_moves.any?
    end

    array_of_moves
  end

  def other_player
    @cur_player == @player1 ? @player2 : @player1
  end

  def get_castling_moves(piece)
    # requirements:
    #     The king and the chosen rook are on the player's first rank. (fulfilled by checking of # moves)
    #     Neither the king nor the chosen rook has previously moved.
    #     There are no pieces between the king and the chosen rook.
    #     The king is not currently in check.
    #     TODO The king does not pass through a square that is attacked by an enemy piece.
    #     TODO The king does not end up in check. (True of any legal move.)
    # 'v' will give us all the empty squares around the king. for each direction
    # of castling, we simply need to check to ensure all the spaces are empty
    # REFACTOR-castling
    castling_moves = {}
    return castling_moves unless piece.moves == 0
    return castling_moves if @state == :check

    v = generate_moves_along_path(piece, generate_threat_vector: true)
    queenside = coord_add(piece.position, piece.special_moves(:castling).first)
    kingside =  coord_add(piece.position, piece.special_moves(:castling).last)
    valid_moves = []
    y = @cur_player.home_base == :top ? 8 : 1

    # iterate through the queenside coordinates
    [[4,y],[3,y],[2,y],queenside].each do |move|
      next unless v[move] == :poss_move
      next unless board.piece_at([1,y]).type == :rook &&
      next unless board.piece_at([1,y]).moves == 0
      # TODO: model each move and determine if king would be in check
      castling_moves[queenside] ||= :castling_move
    end

    # iterate through the kingside coordinates
    [[7,y],[6,y],kingside].each do |move|
      next unless v[move] == :poss_move
      next unless board.piece_at([8,y]).type == :rook &&
      next unless board.piece_at([8,y]).moves == 0
      # TODO: model each move and determine if king would be in check
      castling_moves[kingside] ||= :castling_move
    end

    valid_moves.push "#{coord_for_pos(queenside)}" if castling_moves[queenside]
    valid_moves.push "#{coord_for_pos(kingside)}" if castling_moves[kingside]

    @flash.push FLASH_MESSAGES[:castling].gsub("<POS>", valid_moves.join(" or ")) if valid_moves.any?
    castling_moves
  end

  def pos_for_coord(coord_string)
    # converts a notational coordinate (e.g. a4) into a proper coordinate (1,4)
    x = NUMBER_FOR_LETTER[coord_string[0]]
    y = coord_string[1].to_i
    [x, y]
  end

  def coord_for_pos(pos_arr)
    # converts a coordinate (1,1) into a notational coordinate (a1)
    x = NUMBER_FOR_LETTER.invert[pos_arr[0]]
    y = pos_arr[1]
    "#{x}#{y}"
  end


  def player_is_in_check?
    # get all the possible moves the enemy can make. we're looking for moves
    #   that would overlap with the king.
    enemy_possible_moves = possible_moves_for_pieces other_player.pieces
    enemy_possible_moves.keys.include? @cur_player.king.position
  end

  def get_safe_moves
    # if a player is in check, return all the safe moves available that would
    #   would resolve check - if any!

    # get the threat vectors for the current player's king.
    # the 'current player' in this context is the one who is threatened.
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
    safe_moves[:king] = king_legal_moves if king_legal_moves.any?
    safe_moves[:allies] = ally_legal_moves if ally_legal_moves.any? && king_threat_vectors.values.count(:threat_piece) == 1
    safe_moves
  end

  def game_over
    return true
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
