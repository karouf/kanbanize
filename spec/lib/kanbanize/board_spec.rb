require_relative '../../spec_helper'

describe Kanbanize::Board do
  before do
    VCR.insert_cassette 'board', :record => :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  let(:api) { Kanbanize::API.new(KANBANIZE_API_KEY) }
  subject { Kanbanize::Board.new(api, {'id' => '2', 'name' => 'Test board'}) }

  it 'gives access to its id' do
    subject.must_respond_to :id
  end

  it 'gives access to its name' do
    subject.must_respond_to :name
  end

  it 'gives access to its tasks' do
    subject.must_respond_to :tasks
  end

  describe '#initialize' do
    describe 'with valid data' do
      it 'sets the board id from the data provided' do
        subject.id.must_equal 2
      end

      it 'sets the board name from the data provided' do
        subject.name.must_equal 'Test board'
      end
    end

    describe 'with invalid data' do
      it 'raises an ArgumentError if no id is provided' do
        lambda{ Kanbanize::Board.new({'name' => 'Test board'}) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if no name is provided' do
        lambda{ Kanbanize::Board.new({'id' => '2'}) }.must_raise ArgumentError
      end
    end
  end

  describe '#tasks' do
    it 'returns an array of tasks' do
      subject.tasks.must_be_instance_of Array
      subject.tasks.first.must_be_instance_of Kanbanize::Task
    end

    it 'returns the tasks currently on the board' do
      subject.tasks.first.id.must_equal 7
      subject.tasks.first.title.must_equal 'Write Api specs'
      subject.tasks.last.id.must_equal 41
      subject.tasks.last.title.must_equal 'Test30'
    end

    it 'caches its tasks to avoid retrieving them again' do
      tasks = [ {
                  "taskid"                 => "7",
                  "position"               => "0",
                  "type"                   => "Feature request",
                  "assignee"               => "karouf",
                  "title"                  => "Write Api specs",
                  "description"            => "",
                  "subtasks"               => "1",
                  "subtaskscomplete"       => "0",
                  "color"                  => "#b3b340",
                  "priority"               => "Average",
                  "size"                   => nil,
                  "deadline"               => nil,
                  "deadlineoriginalformat" => nil,
                  "extlink"                => nil,
                  "tags"                   => nil,
                  "columnid"               => "progress_2",
                  "laneid"                 => "7",
                  "leadtime"               => 28,
                  "blocked"                => "0",
                  "blockedreason"          => nil,
                  "subtaskdetails"         => [],
                  "columnname"             => "En cours",
                  "lanename"               => "Standard",
                  "columnpath"             => "En cours",
                  "logedtime"              => 0
                }
              ]
      api = Minitest::Mock.new
      api.expect :get_all_tasks, tasks, [2]
      board = Kanbanize::Board.new(api, {'id' => '2', 'name' => 'Test board'})
      board.tasks.first.title.must_equal "Write Api specs"
      board.tasks.first.title.must_equal "Write Api specs"
      api.verify
    end
  end
end
