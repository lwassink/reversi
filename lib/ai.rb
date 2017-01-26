require_relative 'player'
require_relative 'minimax'
require_relative 'board'

class AIPlayer < Player
  def initialize(color, node_limit = 500)
    super(color)
    @node_limit = node_limit
  end

  def get_move(board)
    @board = board
    build_move_tree
    @board.valid_moves(color)[pick_child]
  end

  private

  def build_move_tree
    @root = MNode.new
    @root.data = [@board, color]

    explored_nodes = 0
    queue = [@root]
    while explored_nodes < @node_limit && !queue.empty?
      current_node = queue.shift
      current_node.add_children(next_nodes(current_node))
      queue += current_node.children

      explored_nodes += 1
    end
  end

  def next_nodes(node)
    board, node_color = node.data
    board.valid_moves(node_color).map do |move|
      new_board = board.dup
      new_board.move(node_color, move)
      new_node = MNode.new()
      new_node.data = [new_board, Board.other_color(node_color)]
      new_node
    end
  end

  def pick_child
    @root.minimax(true) do |data|
      leaf_value(data[0])
    end

    @root.children.each_with_index.max[1]
  end

  def leaf_value(board)
    board.count(color) - board.count(Board.other_color(color))
  end
end

