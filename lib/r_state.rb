# Guard agains wrapping around the right edge
R_GUARD = 2**8 + 2**16 + 2**24 + 2**32 + 2**40 + 2**48 + 2**56
# Guard against wrapping around the left edge
L_GUARD = 2**7 + 2**15 + 2**23 + 2**31 + 2**39 + 2**47 + 2**55
# Guard agains leaving the board
B_GUARD = 2**64 - 1

# the delta is the number of bits to shift
# Right moving deltas
R_DELTAS = [-7, 1, 9]
# Left moving deltas
L_DELTAS = [-9, -1, 7]
# Up/down moving deltas
UD_DELTAS = [-8, 8]

require 'benchmark'
require 'byebug'

class RState
  attr_writer :valid_moves

  def initialize
    @current_player = true # true for white, false for black
    @white_positions = 2**27 + 2**36
    @black_positions = 2**28 + 2**35
    @valid_moves = nil # 2**20 + 2**29 + 2**34 + 2**43
  end

  def valid_moves
    unless (@white_positions | @black_positions) ^ (@white_positions ^ @black_positions) == 0
      raise "Black and white positions may not overlap"
    end

    return @valid_moves if @valid_moves

    v = 0 # valid moves
    i = 1 # location: use i to iterate over the Board
    o = @white_positions | @black_positions # ocupied positions

    # iterate through each board position
    64.times do
      # check if the square is ocupied
      if i & o == 0
        # if not, check if that position would capture
        v = v | i if would_capture?(i)
      end
      i = i << 1
    end

    @valid_moves = v
  end

  def move(pos)
    @valid_moves = nil # reset valid moves
    self.my_positions = my_positions | pos # place a pice
    capture_pieces(pos)
  end

  def switch_players!
    @current_player = !@current_player
    @valid_moves = nil
  end

  def current_player
    @current_player ? :w : :b
  end

  def capture_pieces(pos)
    R_DELTAS.each do |delta|
      i = pos << delta # translate by delta
      # stop with this delta if it's not the other color
      next unless (i & their_positions == i)
      line_to_capture = i # pices to flip

      # loop till you wrap or leave the board
      until (i & B_GUARD == 0 || i & R_GUARD == i)
        # flip if we get to our piece
        if (i & my_positions == i)
          self.their_positions = their_positions ^ line_to_capture
          self.my_positions = my_positions | line_to_capture
        end
        # stop looping once we finish with their pieces
        break unless (i & their_positions == i)
        line_to_capture = line_to_capture | i
        i = i << delta
      end
    end

    L_DELTAS.each do |delta|
      i = pos << delta
      next unless (i & their_positions == i)
      line_to_capture = i

      until (i & B_GUARD == 0 || i & L_GUARD == i)
        if (i & my_positions == i)
          self.their_positions = their_positions ^ line_to_capture
          self.my_positions = my_positions | line_to_capture
        end

        break unless (i & their_positions == i)
        line_to_capture = line_to_capture | i
        i = i << delta
      end
    end

    UD_DELTAS.each do |delta|
      i = pos << delta
      next unless (i & their_positions == i)
      line_to_capture = i

      until (i & B_GUARD == 0)
        if (i & my_positions == i)
          self.their_positions = their_positions ^ line_to_capture
          self.my_positions = my_positions | line_to_capture
        end

        break unless (i & self.their_positions == i)
        line_to_capture = line_to_capture | i
        i = i << delta
      end
    end
  end

  def would_capture?(pos)
    R_DELTAS.each do |delta|
      i = pos << delta # translate by delta
      # stop with this delta if it's not the other color
      next unless (i & their_positions == i)

      # loop till you wrap or leave the board
      until (i & B_GUARD == 0 || i & R_GUARD == i)
        # capture if we get to our piece
        return true if (i & my_positions == i)
        # stop looping once we finish with their pieces
        break unless (i & their_positions == i)
        i = i << delta
      end
    end

    L_DELTAS.each do |delta|
      i = pos << delta
      next unless (i & their_positions == i)

      until (i & B_GUARD == 0 || i & L_GUARD == i)
        return true if (i & my_positions == i)
        break unless (i & their_positions == i)
        i = i << delta
      end
    end

    UD_DELTAS.each do |delta|
      i = pos << delta
      next unless (i & their_positions == i)

      until (i & B_GUARD == 0)
        return true if (i & my_positions == i)
        break unless (i & their_positions == i)
        i = i << delta
      end
    end

    false # return false if we don't capture
  end

  def to_a_of_a
    white_positions = @white_positions
    black_positions = @black_positions
    valid_moves = self.valid_moves
    a_of_a = Array.new(8) { Array.new(8) }
    64.times do |i|
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

  def my_positions
    @current_player ? @white_positions : @black_positions
  end

  def my_positions=(value)
    @current_player ? @white_positions = value : @black_positions = value
  end

  def their_positions
    @current_player ? @black_positions : @white_positions
  end

  def their_positions=(value)
    @current_player ? @black_positions = value : @white_positions = value
  end
end

if __FILE__ == $PROGRAM_NAME
  s = RState.new
  puts s.to_s

  Benchmark.bm do |x|
    x.report { 5000.times { s.valid_moves } }
  end

  # Benchmark.bm do |x|
  #   x.report do
  #     10000.times do
  #       t = RState.new
  #       t.move(2**20)
  #     end
  #   end
  # end
  # s.move(2**20)
  puts s.to_s
end
