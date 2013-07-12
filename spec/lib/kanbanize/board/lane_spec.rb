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
                  {'columns' => [],
                   'lanes' => [{
                                'lcname' => 'Standard',
                                'color' => '#FFFFFF',
                                'description' => ''
                              }]
                  },
                  [2]
      board = Kanbanize::Board.new(api, {'id' => '2', 'name' => 'Test board'})
      board.lane('Standard').tasks.first.title.must_equal "Write Api specs"
      board.lane('Standard').tasks.first.title.must_equal "Write Api specs"
      api.verify
    end
  end

  describe '#tasks!' do
    it 'returns an array of tasks' do
      lane.tasks.must_be_instance_of Array
      lane.tasks.first.must_be_instance_of Kanbanize::Task
    end

    it 'returns the tasks that are in this column' do
      lane.tasks.first.title.must_equal 'Write Api specs'
      lane.tasks.each do |task|
        task.lane.must_equal lane
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
                  {'columns' => [],
                   'lanes' => [{
                                'lcname' => 'Standard',
                                'color' => '#FFFFFF',
                                'description' => ''
                              }]
                  },
                  [2]
      board = Kanbanize::Board.new(api, {'id' => '2', 'name' => 'Test board'})
      board.lane('Standard').tasks!.first.title.must_equal "Write Api specs"
      board.lane('Standard').tasks!.first.title.must_equal "Write API specifications"
      api.verify
    end
  end
end

