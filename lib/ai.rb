require_relative 'player'
require_relative 'reversi_node'
require_relative 'r_state'
require_relative 'board'

class AIPlayer < Player
  def initialize(color, max_level)
    super(color)
    @max_level = max_level
  end

  def get_move(board)
    root = RNode.new(RState.parse_board(board, player))
    root.minimax(white: player, max_level: @max_level)
    moves = RState.bit_array(root.state.valid_moves)
    moves = moves.map { |move| Math.log2(move).to_i }
    Board.coords(moves[best_child(root)])
  end

  private

  def player
    @color == :w
  end

  def best_child(root)
    root.children.each_with_index.max[1]
  end
end
