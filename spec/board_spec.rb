require 'rspec'
require_relative 'spec_helper'

context "Board" do
  let(:starting) { Board.new }

  let(:white_wins) do
    grid = Array.new(64)
    (0..32).each { |i| grid[i] = :w }
    (33..63).each { |i| grid[i] = :b }
    Board.new(grid)
  end

  let(:tie) do
    grid = Array.new(64)
    (0..31).each { |i| grid[i] = :w }
    (32..63).each { |i| grid[i] = :b }
    Board.new(grid)
  end

  let(:over_but_not_full) do
    grid = Array.new(64)
    (0..7).each { |i| grid[i] = :w }
    grid[16] = :w
    grid[23] = :b
    (56..63).each { |i| grid[i] = :b }
    Board.new(grid)
  end

  describe "::pos" do
    it "correctly calculates a pos from coords" do
      expect(Board.pos([1,2])).to be(10)
    end

    it "is the inverse of coords" do
      pos = (0..7).to_a.sample
      expect(Board.pos(Board.coords(pos))).to be(pos)
    end
  end

  describe "::coords" do
    it "correctly calculates coords from a pos" do
      expect(Board.pos([1,2])).to be(10)
    end

    it "is the inverse of pos" do
      row = (0..7).to_a.sample
      col = (0..7).to_a.sample
      expect(Board.coords(Board.pos([row, col]))).to eq([row, col])
    end
  end

  describe "#valid_move?" do
    it "recognizes a valid move" do
      expect(starting.valid_move?(:w, [3, 5])).to be_truthy
    end

    it "doesn't allow moves into occupied spaces" do
      expect(starting.valid_move?(:w, [3, 3])).to be_falsey
    end

    it "doesn't allow moves that don't capture" do
      expect(starting.valid_move?(:w, [3, 2])).to be_falsey
    end

    it "doesn't allow wrapping captures" do
      expect(over_but_not_full.valid_move?(:b, [1, 0])).to be_falsey
      expect(over_but_not_full.valid_move?(:w, [2, 6])).to be_falsey
    end
  end

  describe "#winner" do
    it "returns the color of the winner" do
      expect(white_wins.winner).to eq("white")
    end

    it "returns false when the game is a tie" do
      expect(tie.winner).to be(false)
    end
  end

  describe "#over?" do
    it "knows a full board is over" do
      expect(white_wins.over?).to be_truthy
      expect(tie.over?).to be_truthy
    end

    it "recognizes over boards that aren't full" do
      expect(over_but_not_full.over?).to be_truthy
    end

    it "knows a starting board isn't over" do
      expect(starting.over?).to be_falsey
    end
  end

  describe "#can_move?" do
    it "returns false when there are no valid moves" do
      expect(over_but_not_full.can_move?(:w)).to be_falsey
      expect(over_but_not_full.can_move?(:b)).to be_falsey
    end

    it "returns true for a starting board" do
      expect(starting.can_move?(:w)).to be_truthy
      expect(starting.can_move?(:b)).to be_truthy
    end
  end


  describe ":other_color" do
    it "switches :b to :w" do
      expect(Board.other_color(:b)).to be(:w)
    end

    it "switches :w to :b" do
      expect(Board.other_color(:w)).to be(:b)
    end
  end
end
