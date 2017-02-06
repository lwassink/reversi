require_relative 'r_state'
require_relative 'board'
require 'benchmark'

ZONES = [
  :center,
  :outer_center,
  :inner_edge,
  :edge,
  :corner
]

SCORES = {
  center: 3,
  outer_center: 5,
  inner_edge: 1,
  edge: 7,
  corner: 10
}

POSITIONS = {
  center: [27, 28, 35, 36],
  outer_center: [18, 19, 20, 21, 26, 29, 34, 37, 42, 43, 44, 45],
  inner_edge: [9, 10, 11, 12, 13, 14, 17, 22, 25, 30, 33, 38, 41, 46, 49, 50, 51, 52, 53, 54],
  edge: [1, 2, 3, 4, 5, 6, 8, 15, 16, 23, 24, 31, 32, 39, 40, 47, 48, 55, 57, 58, 59, 60, 61, 62],
  corner: [0, 7, 56, 63]
}

class RNode
  attr_reader :children
  attr_reader :parent
  attr_reader :level
  attr_accessor :value
  attr_accessor :state

  include Comparable

  def initialize(state = nil, value = 0)
    @state = state
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

  def minimax(options)
    default_options = {
      level: 0,
      max: true,
      alpha: -1000,
      beta: 1000
    }
    options = default_options.merge(options)
    @level = options[:level]

    if (options[:level] < options[:max_level]) && @state.can_move?
      RState.bit_array(@state.valid_moves).each do |move|
        # create child node for possible move
        cstate = @state.dup
        cstate.move(move)
        switch = cstate.can_move? # if true, other player can move

        child_options = {}.merge(options)
        child_options[:level] += 1

        # cstate.switch_players! unless switch
        child_options[:max] = !child_options[:max] if switch

        child = RNode.new(cstate)
        self.add_child(child)
        child.minimax(child_options)

        options[:alpha] = [options[:alpha], child.value].max if options[:max]
        options[:beta] = [options[:beta], child.value].min if !options[:max]
        break if options[:alpha] >= options[:beta]
      end

      # calculate value based on child values
      values = @children.map(&:value)
      @value = options[:max] ? values.max : values.min
    else
      # value of leaf determined by evaluation function
      @value = @state.count_evaluate(options[:white])
    end
  end

  def level_order(&blk)
    queue = [self]
    until queue.empty?
      node = queue.pop
      blk.call(node)
      queue += node.children
    end
  end

  def to_s
    puts
    puts "Value: #{@value}"
    puts @state.to_s
    puts
  end

  def <=>(other)
    @value <=> other.value
  end
end


if __FILE__ == $PROGRAM_NAME

  def minimax_test(max_level)
    state = RState.new
    node = RNode.new(state)
    node.minimax(white: true, max_level: max_level)
  end

  # node.minimax(white: true, max_level: 1)

  # node.level_order { |n| puts n.level; puts n.to_s }

  Benchmark.bm do |x|
    x.report { minimax_test(5) }
    x.report { minimax_test(6) }
    x.report { minimax_test(7) }
    x.report { minimax_test(8) }
    x.report { minimax_test(9) }
  end
end
