class Board
  GAME_START = Array.new(64)
  GAME_START[27] = :w
  GAME_START[28] = :b
  GAME_START[35] = :b
  GAME_START[36] = :w

  DELTAS = [-9, -8, -7, -1, 1, 7, 8, 9]

  attr_reader :grid

  def self.pos(coords)
    row, col = coords
    8 * col + row
  end

  def initialize(state = nil)
    @grid = state || GAME_START
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

  def [](row, col)
    @grid[8 * row + col]
  end

  def move(color, pos)
    @grid[pos] = color
    flip_captured_pieces!(color, pos)
  end

  def self.coords(pos)
    [pos % 8, pos / 8]
  end

  def valid_move?(color, pos)
    !captured_positions(color, pos).empty?
  end

  def winner
    white = grid.count(:w)
    black = grid.count(:b)
    return false if white == black
    white > black ? "white" : "black"
  end

  def over?
    grid.count(nil) == 64
  end

  private

  def other_color(color)
    color == :w ? :b : :w
  end

  def captured_positions(color, pos)
    positions = []

    DELTAS.each do |delta|
      line = line(other_color(color), delta, pos)
      positions += line if !line.empty? && grid[line.last + delta] == color
    end

    positions
  end

  def line(color, delta, pos)
    next_pos = pos + delta
    line = []

    while grid[next_pos] == color
      line << next_pos
      next_pos += delta
    end

    line
  end

  def flip_captured_pieces!(color, pos)
    captured_positions(color, pos).each do |pos1|
      @grid[pos1] = color
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  b = Board.new
  puts b.to_s
  p b.valid_moves(:w)
  p b.valid_moves(:w).map { |pos| Board.coords(pos) }
  p b.valid_moves(:b)
  p b.valid_moves(:b).map { |pos| Board.coords(pos) }
end

