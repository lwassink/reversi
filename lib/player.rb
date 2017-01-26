class Player
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def get_move(_)
    raise "You must overwrite the Player#get_move method"
  end

  def to_s
    color == :w ? "white" : "black"
  end
end

