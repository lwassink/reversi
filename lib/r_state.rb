class RState
  def initialize
    @current_player = true # true for white, false for black
    @white_positions = 2**27 + 2**36
    @black_positions = 2**28 + 2**35
    @valid_moves = 2**20 + 2**29 + 2**34 + 2**43
  end

  def left
    @white_positions = @white_positions >> 1
    @black_positions = @black_positions >> 1
    @valid_moves = @valid_moves >> 1
  end

  def right
    @white_positions = @white_positions << 1
    @black_positions = @black_positions << 1
    @valid_moves = @valid_moves << 1
  end

  def up
    @white_positions = @white_positions >> 8
    @black_positions = @black_positions >> 8
    @valid_moves = @valid_moves >> 8
  end

  def down
    @white_positions = @white_positions << 8
    @black_positions = @black_positions << 8
    @valid_moves = @valid_moves << 8
  end

  def to_a_of_a
    white_positions = @white_positions
    black_positions = @black_positions
    valid_moves = @valid_moves
    a_of_a = Array.new(8) { Array.new(8) }
    63.times do |i|
      occupant = nil

      occupant = :w if white_positions % 2 == 1
      occupant = :b if black_positions % 2 == 1
      occupant = :v if valid_moves % 2 == 1

      a_of_a[i / 8][i % 8] = occupant

      white_positions = white_positions / 2
      black_positions = black_positions / 2
      valid_moves = valid_moves / 2
    end
    a_of_a
  end

  def to_s
    array_rep = self.to_a_of_a
    print_string = "Current player: #{@current_player ? 'white' : 'black'}\n"
    print_string += "   "
    print_string += (1..8).to_a.join(" ")

    (0..7).each do |row|
      print_string += "\n #{row + 1}"
      (0..7).each do |col|
        print_string += " #{array_rep[row][col] || "_"}"
      end
    end

    print_string
  end
end

if __FILE__ == $PROGRAM_NAME
  s = RState.new
  puts s.to_s
  s.left
  puts s.to_s
  s.up
  puts s.to_s
  s.right
  puts s.to_s
  s.down
  puts s.to_s
end
