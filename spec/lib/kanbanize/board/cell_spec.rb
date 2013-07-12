require_relative '../../../spec_helper'

describe Kanbanize::Board::Cell do
  before do
    VCR.insert_cassette 'board/cell', :record => :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  let(:api) { Kanbanize::API.new(KANBANIZE_API_KEY) }
  let(:board) { Kanbanize::Board.new(api, {'id' => '2', 'name' => 'Test board'}) }
  let(:column) { board.column('En cours') }
  let(:lane) { board.lane('Standard') }
  let(:cell) { Kanbanize::Board::Cell.new(column, lane) }

  it 'gives access to the column it belongs to' do
    cell.must_respond_to :column
  end

  it 'gives access to the lane it belongs to' do
    cell.must_respond_to :lane
  end

  it 'gives access to its tasks' do
    cell.must_respond_to :tasks
  end

  describe '#column' do
    it 'returns a column' do
      cell.column.must_be_instance_of Kanbanize::Board::Column
    end

    it 'returns the column it belongs to' do
      cell.column.name.must_equal 'En cours'
    end
  end

  describe '#lane' do
    it 'returns a lane' do
      cell.lane.must_be_instance_of Kanbanize::Board::Lane
    end

    it 'returns the lane it belongs to' do
      cell.lane.name.must_equal 'Standard'
    end
  end

  describe '#tasks' do
    it 'returns an array of tasks' do
      cell.tasks.must_be_instance_of Array
      cell.tasks.first.must_be_instance_of Kanbanize::Task
    end

    it 'returns the tasks contained in the cell' do
      cell.tasks.first.title.must_equal 'Write Api specs'
    end
  end
end
