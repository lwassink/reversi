require_relative 'player'

class HumanPlayer < Player
  def get_move(board)
    move = request_move

    until board.valid_move?(color, move)
      move = request_valid_move
    end

    move
  end

  private

  def request_move
    print "Please enter a move (i.e. 1, 2 or 8,8): "
    parse_coords(gets.chomp)
  end

  def request_valid_move
    print "That move is not valid. Please enter a valid move: "
    coords = parse_pos(gets.chomp)
    Board.pos(coords)
  end

  def parse_coords(move)
    move.split(",").map { |word| word.to_i - 1 }
  end
end
