Board positions are ints between 0 and 63.
Board state is a length 64 array with :b, :w, or nill at each position.

The game will recieve two player objects: player1 and player2

A player will recieve the get_move messge and be passed a board object.
The board has a grid method that returns the board state.
Player#get_move must return a number from 0 through 63; the position where they wish to place a piece.

