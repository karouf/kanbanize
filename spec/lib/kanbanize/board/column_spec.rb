require_relative '../../../spec_helper'

describe Kanbanize::Board::Column do
  before do
    VCR.insert_cassette 'board/column', :record => :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  let(:api) { Kanbanize::API.new(KANBANIZE_API_KEY) }
  let(:board) { Kanbanize::Board.new(api, {'id' => '2', 'name' => 'Test board'}) }
  let(:column) { board.column('En cours') }
  let(:lane) { board.lane('Urgent') }

  it 'gives access to its parent board' do
    column.must_respond_to :board
  end

  it 'gives access to its name' do
    column.must_respond_to :name
  end

  it 'gives access to its position' do
    column.must_respond_to :position
  end

  it 'gives access to a specific cell' do
    column.must_respond_to :lane
    column.must_respond_to :[]
  end

  describe '#board' do
    it 'returns a board' do
      column.board.must_be_instance_of Kanbanize::Board
    end

    it 'returns the board the column belongs to' do
      column.board.name.must_equal 'Test board'
    end
  end

  describe '#name' do
    it 'returns the column name' do
      column.name.must_equal 'En cours'
    end
  end

  describe '#position' do
    it 'returns the column position' do
      column.position.must_equal 1
    end
  end

  describe '#lane' do
    it 'returns a cell' do
      column.lane(lane.name).must_be_instance_of Kanbanize::Board::Cell
    end

    it 'returns the cell from that column and the specified lane' do
      column.lane(lane.name).column.name.must_equal column.name
      column.lane(lane.name).lane.name.must_equal lane.name
    end
  end

  describe '#[]' do
    it 'behaves like #lane' do
      column[lane.name].must_equal column.lane(lane.name)
    end
  end
end
