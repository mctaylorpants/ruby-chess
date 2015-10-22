require "./nil_piece.rb"

class Board
  attr_reader :pieces

  # TODO: best practice for constants, is it OK to use them in the class?
  BOARD_MAX_COORD_X = 8
  BOARD_MAX_COORD_Y = 8

  def initialize
    build_board

  end

  def add_piece(piece, pos_arr)
    # because the array is zero-based, but we want to express the positions as
    #  starting from 1, we have to subtract one to the coordinates before we
    #  can access the correct element in the array.
    pos_x, pos_y = pos_arr
    pieces[array_pos_for pos_x][array_pos_for pos_y] = piece
  end

  def piece_at(pos_arr)
    # returns the piece at this position, or nil if it's empty.
    pos_x, pos_y = pos_arr
    pieces[array_pos_for pos_x][array_pos_for pos_y]
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
      this_piece.owner != piece_at(move_pos).owner
    end


  end

  private
  def build_board
    # - our board is a multi-dimensional array where each outer element is a
    #     row (x), and each inner element is a column (y).
    # - the objects are stored in the columns, but we set them to nil
    #     until we add pieces
    n = NilPiece.new(nil, nil) # see the NilPiece class for details

    @pieces =
              [
                [n, n, n, n, n, n, n, n],
                [n, n, n, n, n, n, n, n],
                [n, n, n, n, n, n, n, n],
                [n, n, n, n, n, n, n, n],
                [n, n, n, n, n, n, n, n],
                [n, n, n, n, n, n, n, n],
                [n, n, n, n, n, n, n, n],
                [n, n, n, n, n, n, n, n],
              ]
  end

  def array_pos_for(i)
    # offsets the coordinate position to return the correct element in the array.
    i - 1
  end

end
