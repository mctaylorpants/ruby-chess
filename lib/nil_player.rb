require "player"

class NilPlayer < Player
  # this class provides a 'nil' player object to use when a nil
  #   piece is trying to figure out its owner (see display.rb)
end
