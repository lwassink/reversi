class Board
  GAME_START = Array.new(64)
  GAME_START[27] = :w
  GAME_START[28] = :b
  GAME_START[35] = :b
  GAME_START[36] = :w

  DELTAS = [
    [1, 0],
    [1, 1],
    [0, 1],
    [-1, 1],
    [-1, 0],
    [-1, -1],
    [0, -1],
    [1, -1]
  ]

  attr_reader :grid

  def initialize(state = nil)
    @grid = state || GAME_START
  end

  def self.pos(coords)
    row, col = coords
    8 * row + col
  end

  def self.coords(pos)
    [pos / 8, pos % 8]
  end

  def [](coords)
    return @grid[Board.pos(coords)] if in_bounds(coords)
    nil
  end

  def []=(coords, value)
    @grid[Board.pos(coords)] = value if in_bounds(coords)
  end

  def to_s
    print_string = "   "
    print_string += (1..8).to_a.join(" ")

    (0..7).each do |row|
      print_string += "\n #{row + 1}"
      (0..7).each do |col|
        print_string += " #{self[row, col] || "_"}"
      end
    end

    print_string
  end

  def valid_moves(color)
    (0..63).to_a.select { |pos| valid_move?(color, pos) }
  end

  def can_move?(color)
    !valid_moves(color).empty?
  end

  def move(color, pos)
    @grid[pos] = color
    flip_captured_pieces!(color, pos)
  end

  def self.coords(pos)
    [pos / 8, pos % 8]
  end

  def valid_move?(color, pos)
    grid[pos].nil? && !captured_positions(color, pos).empty?
  end

  def winner
    white = grid.count(:w)
    black = grid.count(:b)
    return false if white == black
    white > black ? "white" : "black"
  end

  def over?
    !can_move?(:w) && !can_move?(:b)
  end

  def dup
    self.class.new(grid.dup)
  end

  def count(color = nil)
    if color.nil?
      @grid.count { |el| el }
    else
      @grid.count(color)
    end
  end

  def self.other_color(color)
    color == :w ? :b : :w
  end

  def captured_positions(color, pos)
    positions = []

    DELTAS.each do |delta|
      line = line(Board.other_color(color), delta, pos)
      Board.add(Board.coords(line.last), delta) unless line.empty?
      positions += line if !line.empty? && self[*Board.add(Board.coords(line.last), delta)] == color
    end

    positions
  end

  def line(color, delta, pos)
    next_pos = Board.add(Board.coords(pos), delta)
    line = []

    while in_bounds(next_pos) && self[*next_pos] == color
      line << Board.pos(next_pos)
      next_pos = Board.add(next_pos, delta)
    end

    line
  end

  def flip_captured_pieces!(color, pos)
    captured_positions(color, pos).each do |pos1|
      @grid[pos1] = color
    end
  end

  def in_bounds(pos)
    pos.all? { |coord| 0 <= coord && coord < 8 }
  end

  def self.add(pos1, pos2)
    [pos1[0] + pos2[0],
     pos1[1] + pos2[1]]
  end
end

if __FILE__ == $PROGRAM_NAME
  b = Board.new

  puts b.to_s
  p b.valid_moves(:w)
  p b.valid_moves(:w).map { |pos| Board.coords(pos) }
  p b.can_move?(:w)
  p b.captured_positions(:w, 29)
  p b.valid_move?(:w, 29)
  p b.valid_moves(:b)
  p b.valid_moves(:b).map { |pos| Board.coords(pos) }
  p b.can_move?(:b)

  # c = b.dup
  # c.move(:w, 1)
  # puts b.to_s
  # puts c.to_s
end
