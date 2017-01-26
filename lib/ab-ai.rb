require_relative 'player'
require_relative 'reversi_node'
require_relative 'board'

class ABAIPlayer < Player
  def initialize(color, max_level)
    super(color)
    @max_level = max_level
  end

  def get_move(board)
    root = RNode.new(board)
    root.ab_minimax(color: self.color, max_level: @max_level)
    board.valid_moves(color)[pick_child(root)]
  end

  private

  def pick_child(root)
    root.children.each_with_index.max[1]
  end
end
