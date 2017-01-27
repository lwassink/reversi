Board positions are ints between 0 and 63.
Board state is a length 64 array with :b, :w, or nil at each position.

The game will receive two player objects: player1 and player2

A player will receive the get_move message and be passed a board object.
The board has a grid method that returns the board state.
Player#get_move must return a number from 0 through 63; the position where they wish to place a piece.

# Plan:

* Rethink board structure, evaluation function, etc. Map out algorithm. Plan  
* Lazy evaluation and caching of valid_moves
  * Doubled speed
  * Caching other methods(valid_move? and captured_positions) show no improvement
* Don't switch if the other player can't move
  * Seems to slow things significantly. Probably from calculating valid_moves for both sides at each point
* End the game at the correct time
  * What did I mean by this?
  * Done!
* High leaf_value for a winning position (and low one for a loosing position)
* Quiescence
  * Hard to measure the effect.
  * Maybe I should expand quiescent circumstances
* Web interface
* Tree visualization component
* Weight positions for leaf_value
