require "./piece.rb"

class NilPiece < Piece
  # this class provides a 'nil' piece object to use on the board when a spot
  #   is empty. we use this so that when you do something like 'piece.owner',
  #   it responds correctly.
  # TODO: is this a good way of solving this problem?
end