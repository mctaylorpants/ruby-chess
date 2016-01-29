class Player
  attr_reader   :name
  attr_reader   :home_base
  attr_reader   :num_moves

  def initialize(name, home_base)
    @name = name
    @home_base = home_base
    @num_moves = 0
    @pieces = {}
  end

  def increment_move_count
    @num_moves += 1
  end

  def assign_piece(piece)
    return if piece.class == NilPiece
    if piece.class == King || piece.class == Queen
      key = "#{piece.class.to_s}".to_sym
    else
      # I wanted to use the position here, but it actually
      #   doesn't get set until the board gets set up. So
      #   I used object_id because I'm lazy and I don't think
      #   it will matter...
      key = "#{piece.class.to_s}_#{piece.object_id}".to_sym
    end
    @pieces[key] = piece
  end

  def pieces
    @pieces.values
  end

  def king
    @pieces[:King]
  end

end
