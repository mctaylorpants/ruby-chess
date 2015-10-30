require "./nil_piece.rb"
require "./nil_player.rb"

class Board
  include ChessHelpers
  attr_reader :pieces

  def initialize
    build_board
  end

  def add_piece(piece, pos_arr)
    # because the array is zero-based, but we want to express the positions as
    #  starting from 1, we have to subtract one to the coordinates before we
    #  can access the correct element in the array.
    pos_x, pos_y = pos_arr

    # remember, when storing in our array, we store by y,x, not by x,y.
    pieces[array_pos_for pos_y][array_pos_for pos_x] = piece
  end

  def piece_at(pos_arr)
    # returns the piece at this position, or nil if it's empty.
    pos_x, pos_y = pos_arr

    # remember, in the array, we store by y,x, not by x,y.
    pieces[array_pos_for pos_y][array_pos_for pos_x]
  end

  def move_piece(piece, pos_arr)
    # moves a piece on the board; returns the existing piece if one was
    #   there already.
    cur_pos_x, cur_pos_y = piece.position
    new_pos_x, new_pos_y = pos_arr

    # replace the old position with an empty square
    add_piece new_nil_piece, piece.position

    # add the piece to the new position
    add_piece piece, pos_arr

    piece.position = [new_pos_x, new_pos_y]

    piece.moves += 1
  end


  private
  def build_board
    # - our board is a multi-dimensional array where each outer element is a
    #     column (y), and each inner element is a row (x).
    # - the objects are stored in the columns, but we set them to nil
    #     until we add pieces

    n = new_nil_piece
      # see the NilPiece and NilPlayer class for details

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

  def new_nil_piece
    NilPiece.new(nil, NilPlayer.new(nil, nil))
  end


end
