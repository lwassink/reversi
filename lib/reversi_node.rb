require_relative 'board'
require 'benchmark'

class RNode
  attr_reader :children
  attr_reader :parent
  attr_accessor :value
  attr_accessor :board

  include Comparable

  def initialize(board = nil, value = 0)
    @board = board
    @value = value
    @parent = nil
    @children = []
  end

  def parent=(other)
    @parent.children.delete!(self) unless @parent.nil?
    @parent = other
    other.children << self
  end

  def add_child(other)
    other.parent = self
  end

  def add_children(others)
    others.each { |other| other.parent = self }
  end

  def po
    @children.each { |child| child.post_order }

    yield(self)
  end

  def df
    yield(self)

    @children.each { |child| child.dfs }
  end

  def bf
    queue = [self]
    until queue.empty?
      node = queue.shift
      yield(node)
      queue += node.children
    end
  end

  def minimax(options)
    default_options = {
      level: 0,
      max: true
    }
    options = default_options.merge(options)

    if options[:level] < options[:max_level] &&
      @board.can_move?(options[:color])
      @board.valid_moves(options[:color]).each do |pmove|
        pboard = @board.dup
        pboard.move(options[:color], pmove)
        self.add_child(RNode.new(pboard))
        @children.last.minimax(
          level: options[:level] + 1,
          max: !options[:max],
          max_level: options[:max_level],
          color: Board.other_color(options[:color])
        )
      end

      values = @children.map(&:value)
      @value = options[:max] ? values.max : values.min
    else
      @value = self.leaf_value(options[:color], options[:level])
    end
  end

  def ab_minimax(options)
    default_options = {
      level: 0,
      max: true,
      alpha: -65,
      beta: 65
    }
    options = default_options.merge(options)

    if options[:level] < options[:max_level] &&
      @board.can_move?(options[:color])
      @board.valid_moves(options[:color]).each do |pmove|
        pboard = @board.dup
        pboard.move(options[:color], pmove)
        child = RNode.new(pboard)
        self.add_child(child)

        child.ab_minimax(
          level: options[:level] + 1,
          max: !options[:max],
          max_level: options[:max_level],
          color: Board.other_color(options[:color]),
          alpha: options[:alpha],
          beta: options[:beta]
        )

        if options[:max]
          options[:alpha] = [options[:alpha], child.value].max
        else
          options[:beta] = [options[:beta], child.value].min
        end

        break if options[:alpha] >= options[:beta]
      end

      values = @children.map(&:value)
      @value = options[:max] ? values.max : values.min
    else
      @value = self.leaf_value(options[:color], options[:level])
    end
  end

  def to_s
    puts
    puts "Value: #{@value}"
    puts @board.to_s
    puts
  end

  def <=>(other)
    @value <=> other.value
  end

  def leaf_value(color, level)
    color = Board.other_color(color) if level.odd?
    @board.count(color) - @board.count(Board.other_color(color))
  end
end

if __FILE__ == $PROGRAM_NAME
  board = Board.new
  board.move(:w, [2, 4])
  ab_board = board.dup

  node = RNode.new(board)
  ab_node = RNode.new(ab_board)

  Benchmark.bm do |x|
    x.report { node.minimax(color: :b, max_level: 5) }
    x.report { ab_node.ab_minimax(color: :b, max_level: 5) }
    # x.report { node.minimax(color: :b, max_level: 6) }
    # x.report { ab_node.ab_minimax(color: :b, max_level: 6) }
    # x.report { ab_node.ab_minimax(color: :b, max_level: 7) }
    # x.report { ab_node.ab_minimax(color: :b, max_level: 8) }
    # x.report { node.minimax(color: :b, max_level: 8) }
  end

  node.children.each { |child| puts child.to_s }
  ab_node.children.each { |child| puts child.to_s }
end
