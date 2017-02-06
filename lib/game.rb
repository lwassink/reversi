require_relative 'human_player'
require_relative 'ai'
require_relative 'ai'
require_relative 'board'
require 'byebug'

class Game
  def initialize(player1, player2, board)
    @player1 = player1
    @player2 = player2
    @board = board
  end

  def run
    until over?
      display_state
      make_move
    end

    end_game
  end

  private

  def display_state
    # system("clear")
    puts
    puts @board.to_s
    puts
    puts "It's the #{current_player} player's turn."
  end

  def make_move
    pos = current_player.get_move(@board)
    @board.move(current_player.color, pos)
    switch_players! if @board.can_move?(other_player.color)
  end

  def current_player
    @current_player ||= @player1
  end

  def other_player
    current_player == @player1 ? @player2 : @player1
  end

  def switch_players!
    @current_player = other_player
  end

  def over?
    @board.over?
  end

  def end_game
    puts
    puts @board.to_s
    puts
    if @board.winner
      puts "Congratulations, #{@board.winner}, you win!"
    else
      puts "It's a tie!"
    end
    puts "White: #{@board.count(:w)}, Black: #{@board.count(:b)}"
  end
end

if __FILE__ == $PROGRAM_NAME
  # player1 = HumanPlayer.new(:w)
  move_limit = 5
  player1 = AIPlayer.new(:w, move_limit)
  player2 = AIPlayer.new(:b, move_limit)

  grid = Array.new(64, :w)
  board = Board.new

  game = Game.new(player1, player2, board)
  game.run
end
