require_relative 'r_state'
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

    if (options[:level] < options[:max_level] || options[:quies]) &&
      @state.can_move?(options[:color])

      @state.valid_moves(options[:color]).each do |pmove|
        # create child node for possible move
        pstate = @state.dup
        pstate.move(options[:color], pmove)
        child = RNode.new(pstate)
        self.add_child(child)

        child_options = {
          level: options[:level] + 1,
          max_level: options[:max_level],
          alpha: options[:alpha],
          beta: options[:beta]
        }

        # only switch if other player can move
        if pstate.can_move?(Board.other_color(options[:color]))
          child_options[:color] = Board.other_color(options[:color])
          child_options[:max] = !options[:max]
        else
          child_options[:color] = options[:color]
          child_options[:max] = options[:max]
          child_options[:quies]
        end

        child.minimax(child_options)

        # update alpha or beta based on child values
        if options[:max]
          options[:alpha] = [options[:alpha], child.value].max
        else
          options[:beta] = [options[:beta], child.value].min
        end

        break if options[:alpha] >= options[:beta]
      end

      # calculate value based on child values
      values = @children.map(&:value)
      @value = options[:max] ? values.max : values.min
    else
      # value of leaf determined by leaf_value
      @value = self.leaf_value(options[:color], options[:level], options[:max])
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

  def leaf_value(color, level, max)
    # switch color if it's the other guys turn
    # this ensures a positive score is good for the root node color
    color = Board.other_color(color) unless max
    oc = Board.other_color(color)

    if @state.over?
      return 0 unless @state.winner
      return 65 if @state.winner == color
      return -65 if @state.winner != color
    end

    val = 0
    ZONES.each do |zone|
      POSITIONS[zone].each do |pos|
        if @state.grid[pos] == color
          val += SCORES[zone]
        elsif @state.grid[pos] == oc
          val -= SCORES[zone]
        end
      end
    end
    val
  end
end

if __FILE__ == $PROGRAM_NAME
  state = Board.new
  state.move(:w, [2, 4])
  node = RNode.new(state)

  Benchmark.bm do |x|
    x.report { node.minimax(color: :b, max_level: 5) }
    x.report { node.minimax(color: :b, max_level: 6) }
    x.report { node.minimax(color: :b, max_level: 7) }
    x.report { node.minimax(color: :b, max_level: 8) }
    # x.report { node.minimax(color: :b, max_level: 9) }
  end

  # positions = []
  # ZONES.each do |zone|
  #   positions += POSITIONS[zone]
  # end
  # p positions
  # p positions.length
  # p positions.uniq
  # p positions.uniq.length
  # p (0..63).to_a - positions.uniq

  # node.children.each { |child| puts child.to_s }
end
