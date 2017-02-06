# Development Log

## Board class

### 1/28/17

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

### 1/28/17

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


## RNode class

### 2/3/17

-- Calculates move tree and selects best move
-- Benchmark RNode#minimax with weighted evaluation function, quiescence, and alpha-beta pruning
Benchmark.bm do |x|
  x.report { node.minimax(color: :b, max_level: 5) }
  x.report { node.minimax(color: :b, max_level: 6) }
  x.report { node.minimax(color: :b, max_level: 7) }
  x.report { node.minimax(color: :b, max_level: 8) }
end

     user     system      total        real
 0.910000   0.000000   0.910000 (  0.930749)
 3.940000   0.030000   3.970000 (  4.027431)
11.720000   0.150000  11.870000 ( 12.416911)
46.470000   0.480000  46.950000 ( 48.306214)
-- with simple evaluation function (only use counts)
     user     system      total        real
 0.530000   0.010000   0.540000 (  0.559358)
 1.390000   0.020000   1.410000 (  1.431128)
 5.010000   0.030000   5.040000 (  5.111925)
15.230000   0.080000  15.310000 ( 15.453500)


-- Now with RState instead of Board, no alpha-beta, no weighting, and no quiescence
Benchmark.bm do |x|
  x.report { node.minimax(white: false, max_level: 5) }
  x.report { node.minimax(white: false, max_level: 6) }
  x.report { node.minimax(white: false, max_level: 7) }
  x.report { node.minimax(white: false, max_level: 8) }
end
-- Results:
user     system      total        real
0.490000   0.000000   0.490000 (  0.500979)
1.750000   0.020000   1.770000 (  1.807364)
5.570000   0.070000   5.640000 (  5.777553)
17.490000   0.150000  17.640000 ( 18.236735)

### 2/6/17
-- Now with RState and alpha-beta pruning and basic quiescence. Test code:
def minimax_test(max_level)
  state = RState.new
  node = RNode.new(state)
  node.minimax(white: true, max_level: max_level)
end

Benchmark.bm do |x|
  x.report { minimax_test(5) }
  x.report { minimax_test(6) }
  x.report { minimax_test(7) }
  x.report { minimax_test(8) }
  x.report { minimax_test(9) }
end
-- Results:
user     system      total        real
0.050000   0.000000   0.050000 (  0.060084)
0.240000   0.010000   0.250000 (  0.235813)
0.440000   0.000000   0.440000 (  0.455991)
1.960000   0.010000   1.970000 (  1.996421)
4.390000   0.030000   4.420000 (  4.468009)
