class MNode
  attr_reader :children
  attr_reader :parent
  attr_accessor :value
  attr_accessor :data

  include Comparable

  def initialize(data = nil, value = 0)
    @data = data
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

  def minimax(max, &prc)
    prc ||= Proc.new { nil }

    @children.each { |child| child.minimax(!max, &prc) }

    if @children.empty?
      @value = prc.call(@data) || @value
    else
      @value = max ? @children.map(&:value).max :
        @children.map(&:value).min
    end
  end

  def <=>(other)
    self.value <=> other.value
  end
end

if __FILE__ == $PROGRAM_NAME
  a = MNode.new
  b = MNode.new
  b.parent = a
  c = MNode.new
  c.parent = a
  d = MNode.new
  d.parent = b
  e = MNode.new
  e.parent = b
  f = MNode.new
  f.parent = c
  g = MNode.new
  g.parent = c
  h = MNode.new
  h.parent = d
  h.value = 1
  i = MNode.new
  i.parent = d
  i.value = 2
  j = MNode.new
  j.parent = e
  j.value = 5
  k = MNode.new
  k.parent = e
  k.value = 3
  l = MNode.new
  l.parent = f
  l.value = -1
  m = MNode.new
  m.parent = f
  m.value = 5
  n = MNode.new
  n.parent = g
  n.value = 7
  o = MNode.new
  o.parent = g
  o.value = 4

  a.minimax(true)
  a.bf { |node| p node.value }
  puts
  a.minimax(false)
  a.bf { |node| p node.value }
end

