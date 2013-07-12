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

  it 'gives access to its tasks' do
    column.must_respond_to :tasks
    column.must_respond_to :tasks!
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

  describe '#tasks' do
    it 'returns an array of tasks' do
      column.tasks.must_be_instance_of Array
      column.tasks.first.must_be_instance_of Kanbanize::Task
    end

    it 'returns the tasks that are in this column' do
      column.tasks.first.title.must_equal 'Write Api specs'
      column.tasks.each do |task|
        task.column.must_equal column
      end
    end

    it 'caches the tasks to avoid retrieving them again' do
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
      api.expect :get_board_structure,
                  {'columns' => [{
                                  'position' => '1',
                                  'lcname' => 'En cours',
                                  'description' => 'Ce qui est en cours',
                                  'tasksperrow' => '3'
                                }],
                   'lanes' => []
                  },
                  [2]
      board = Kanbanize::Board.new(api, {'id' => '2', 'name' => 'Test board'})
      board.column('En cours').tasks.first.title.must_equal "Write Api specs"
      board.column('En cours').tasks.first.title.must_equal "Write Api specs"
      api.verify
    end
  end

  describe '#tasks!' do
    it 'returns an array of tasks' do
      column.tasks.must_be_instance_of Array
      column.tasks.first.must_be_instance_of Kanbanize::Task
    end

    it 'returns the tasks that are in this column' do
      column.tasks.first.title.must_equal 'Write Api specs'
      column.tasks.each do |task|
        task.column.must_equal column
      end
    end

    it 'refreshes the tasks from the API' do
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
      refreshed_tasks = [tasks.first.merge('title' => 'Write API specifications')]
      api = Minitest::Mock.new
      api.expect :get_all_tasks, tasks, [2]
      api.expect :get_all_tasks, refreshed_tasks, [2]
      api.expect :get_board_structure,
                  {'columns' => [{
                                  'position' => '1',
                                  'lcname' => 'En cours',
                                  'description' => 'Ce qui est en cours',
                                  'tasksperrow' => '3'
                                }],
                   'lanes' => []
                  },
                  [2]
      board = Kanbanize::Board.new(api, {'id' => '2', 'name' => 'Test board'})
      board.column('En cours').tasks!.first.title.must_equal "Write Api specs"
      board.column('En cours').tasks!.first.title.must_equal "Write API specifications"
      api.verify
    end
  end
end
