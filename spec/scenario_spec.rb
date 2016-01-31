require 'game_controller'

RSpec.describe GameController do
  context 'special moves' do
    let(:gc) { GameController.new }
    before { gc }

    it 'allows en passant' do
      moves = gc.select_piece('c2')
      expect(moves.keys).to include([3,3])
      expect(moves.keys).to include([3,4])
    end

    it 'only allows en passant once' do
      gc.select_piece('c2')
      gc.move_piece('c4')

      gc.select_piece('a7')
      gc.move_piece('a5')

      moves = gc.select_piece('c4')
      expect(moves.keys.count).to eq(1)
    end

    it 'detects check' do
      gc.select_piece('c2')
      gc.move_piece('c3')

      gc.select_piece('d7')
      gc.move_piece('d5')

      gc.select_piece('d1')
      gc.move_piece('a4')
      expect(gc.state).to eq(:check)
    end

    it 'detects checkmate' do
      gc.select_piece('f2')
      gc.move_piece('f4')

      gc.select_piece('e7')
      gc.move_piece('e5')

      gc.select_piece('g2')
      gc.move_piece('g4')

      gc.select_piece('d8')
      gc.move_piece('h4')

      expect(gc.state).to eq(:checkmate)
    end

    pending 'allows castling'
    pending 'allows pawn promotion'
  end
end
