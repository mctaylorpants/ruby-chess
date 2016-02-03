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

    it 'allows castling' do
      gc.select_piece('b1')
      gc.move_piece('a3')

      gc.select_piece('a7')
      gc.move_piece('a6')

      gc.select_piece('b2')
      gc.move_piece('b3')

      gc.select_piece('b7')
      gc.move_piece('b6')

      gc.select_piece('c1')
      gc.move_piece('b2')

      gc.select_piece('c7')
      gc.move_piece('c6')

      gc.select_piece('c2')
      gc.move_piece('c3')

      gc.select_piece('d7')
      gc.move_piece('d6')

      gc.select_piece('d1')
      gc.move_piece('c2')

      gc.select_piece('e7')
      gc.move_piece('e6')

      castling_moves = gc.select_piece('e1')
      expect(castling_moves.keys.count).to eq(2)

      gc.move_piece('c1') # rook should change position
      expect(gc.piece_at('d1')[:type]).to eq(:rook)

    end

    pending 'allows pawn promotion'
  end
end
