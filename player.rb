class Player
  def get_move(_)
    raise "You must overwrite the Player#get_move method"
  end

  def color
    raise "You must overwrite the Player#color method"
  end
end
