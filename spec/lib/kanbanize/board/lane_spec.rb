require_relative '../../../spec_helper'

describe Kanbanize::Board::Lane do
  before do
    VCR.insert_cassette 'board/lane', :record => :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  let(:api) { Kanbanize::API.new(KANBANIZE_API_KEY) }
  let(:board) { Kanbanize::Board.new(api, {'id' => '2', 'name' => 'Test board'}) }
  let(:lane) { board.lane('Standard') }

  it 'gives access to its name' do
    lane.must_respond_to :name
  end

  it 'gives access to its tasks' do
    lane.must_respond_to :tasks
  end

  describe '#name' do
    it 'returns the column name' do
      lane.name.must_equal 'Standard'
    end
  end

  describe '#tasks' do
    it 'returns an array of tasks' do
      lane.tasks.must_be_instance_of Array
      lane.tasks.first.must_be_instance_of Kanbanize::Task
    end

    it 'returns the tasks that are in this lane' do
      lane.tasks.first.title.must_equal 'Write Api specs'
      lane.tasks.each do |task|
        task.lane.must_equal lane
      end
    end
  end
end

