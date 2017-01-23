require_relative 'player'
require_relative 'board'

class HumanPlayer < Player
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def get_move(board)
    move = request_move

    until board.valid_move?(color, move)
      move = request_valid_move
    end

    move
  end

  def to_s
    color == :w ? "white" : "black"
  end

  private

  def request_move
    print "Please enter a move (i.e. 1, 2 or 8,8): "
    coords = parse_pos(gets.chomp)
    Board.pos(coords)
  end

  def request_valid_move
    print "That move is not valid. Please enter a valid move: "
    coords = parse_pos(gets.chomp)
    Board.pos(coords)
  end

  def parse_pos(move)
    move.split(",").reverse.map { |word| word.to_i - 1 }
  end
end

