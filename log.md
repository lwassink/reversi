# Development Log

## Board class

-- Stores board data as a single array of length 64 containing either nil, :w, or :b
-- Benchmark Board#move
  Benchmark.bm do |x|
    x.report do
      10000.times do
        t = Board.new
        t.move(:w, [2,4])
      end
    end
  end

  user     system      total        real
   0.120000   0.000000   0.120000 (  0.124843)

-- Benchmark Board:valid_moves
  b = Board.new
  Benchmark.bm do |x|
    x.report { 5000.times { b.valid_moves(:w) } }
  end

  user     system      total        real
  3.430000   0.030000   3.460000 (  3.592775)

## RState class

-- Stores board state as two 64 bit ints: one for black positions and one for white
-- Also stores valid_moves as an int and current_player as a boolean
-- Benchmark RState#move
  Benchmark.bm do |x|
    x.report do
      10000.times do
        t = RState.new
        t.move(2**20)
      end
    end
  end

  user     system      total        real
   0.040000   0.000000   0.040000 (  0.035898)
-- Benchmark RState#valid_moves
  s = RState.new
  puts s.to_s

  Benchmark.bm do |x|
    x.report { 5000.times { s.valid_moves } }
  end

  user     system      total        real
  0.620000   0.000000   0.620000 (  0.622432)
-- Takeaway: RState is 3 to 4 times faster
