require 'game_controller'

BOARD_INITIAL_STATE = [[{:player=>:bottom, :piece=>:rook}, {:player=>:bottom, :piece=>:knight}, {:player=>:bottom, :piece=>:bishop}, {:player=>:bottom, :piece=>:queen}, {:player=>:bottom, :piece=>:king}, {:player=>:bottom, :piece=>:bishop}, {:player=>:bottom, :piece=>:knight}, {:player=>:bottom, :piece=>:rook}], [{:player=>:bottom, :piece=>:pawn}, {:player=>:bottom, :piece=>:pawn}, {:player=>:bottom, :piece=>:pawn}, {:player=>:bottom, :piece=>:pawn}, {:player=>:bottom, :piece=>:pawn}, {:player=>:bottom, :piece=>:pawn}, {:player=>:bottom, :piece=>:pawn}, {:player=>:bottom, :piece=>:pawn}], [{:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}], [{:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}], [{:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}], [{:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}, {:player=>nil, :piece=>:nil_piece}], [{:player=>:top, :piece=>:pawn}, {:player=>:top, :piece=>:pawn}, {:player=>:top, :piece=>:pawn}, {:player=>:top, :piece=>:pawn}, {:player=>:top, :piece=>:pawn}, {:player=>:top, :piece=>:pawn}, {:player=>:top, :piece=>:pawn}, {:player=>:top, :piece=>:pawn}], [{:player=>:top, :piece=>:rook}, {:player=>:top, :piece=>:knight}, {:player=>:top, :piece=>:bishop}, {:player=>:top, :piece=>:queen}, {:player=>:top, :piece=>:king}, {:player=>:top, :piece=>:bishop}, {:player=>:top, :piece=>:knight}, {:player=>:top, :piece=>:rook}]]

RSpec.describe GameController do
  context 'initialization' do
    it { is_expected.to be_a GameController}
  end

  context 'opening state' do
    gc = GameController.new

    it 'returns an array for board state' do
      expect(gc.board_state).to be_a Array
    end

    it 'sets up the board correctly' do
      expect(gc.board_state).to eq(BOARD_INITIAL_STATE)
    end
  end

  context 'gameplay' do
    let(:gc) { GameController.new }
    before { gc }

    it 'begins with player 1' do
      expect(gc.current_player).to eq(:bottom)
    end

    it 'returns possible moves for a player 1 piece' do
      moves = gc.select_piece('c2')
      expect(moves).to be_a Hash
      expect(moves.keys.count).to eq(2)
    end

    it 'restricts piece selection to player 1 pieces' do
      expect { gc.select_piece('c7') }.to raise_error Game::InvalidSelectionError
    end

    it 'returns possible moves' do
      gc.select_piece('c2')
      possible_moves = gc.possible_moves
      expect(possible_moves).to be_a Hash
      expect(possible_moves.keys.count).to eq(2)
    end

    it 'returns empty hash for possible_moves with no selected piece' do
      possible_moves = gc.possible_moves
      expect(possible_moves).to be_empty
    end

    it 'responds to move_piece' do
      gc.select_piece('c2')
      res = gc.move_piece('c4')
      expect(res).to be true
    end

    it 'only performs legal moves' do
      gc.select_piece('c2')
      res = gc.move_piece('c7')
      expect(res).to be false
      piece = gc.piece_at('c2')
      expect(piece[:type]).to eq(:pawn)
    end
  end

end
