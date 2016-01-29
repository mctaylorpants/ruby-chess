require 'game'

RSpec.describe Game, "scenarios" do
  subject(:game) { Game.new }

  context "end game scenarios" do
    it "results in check" do
      game.api_select_piece(:player1, 'c2').api_move_to('c3')
      game.api_select_piece(:player2, 'd7').api_move_to('d5')
      game.api_select_piece(:player1, 'd1').api_move_to('a4')
      expect(game.state).to eq(:check_player2)
    end

    pending "results in checkmate" do

    end
  end

  context "special moves" do
    pending "allows the pawn to move two squares" do
    end

    pending "allows en passant rules" do
    end

    pending "allows castling" do
    end
  end

  context "movement restrictions" do
    pending "doesn't allow the king to move into check" do
    end
  end

end
