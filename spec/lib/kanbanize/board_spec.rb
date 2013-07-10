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
      api.expect :get_board_structure, {'columns' => [], 'lanes' => []}, [2]
      board = Kanbanize::Board.new(api, {'id' => '2', 'name' => 'Test board'})
      board.tasks.first.title.must_equal "Write Api specs"
      board.tasks.first.title.must_equal "Write Api specs"
      api.verify
    end
  end

  describe '#tasks!' do
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

    it 'forces its tasks to be refreshed from the api' do
      tasks = [ {
                  'taskid'                 => '7',
                  'position'               => '0',
                  'type'                   => 'Feature request',
                  'assignee'               => 'karouf',
                  'title'                  => 'Write Api specs',
                  'description'            => '',
                  'subtasks'               => '1',
                  'subtaskscomplete'       => '0',
                  'color'                  => '#b3b340',
                  'priority'               => 'Average',
                  'size'                   => nil,
                  'deadline'               => nil,
                  'deadlineoriginalformat' => nil,
                  'extlink'                => nil,
                  'tags'                   => nil,
                  'columnid'               => 'progress_2',
                  'laneid'                 => '7',
                  'leadtime'               => 28,
                  'blocked'                => '0',
                  'blockedreason'          => nil,
                  'subtaskdetails'         => [],
                  'columnname'             => 'En cours',
                  'lanename'               => 'Standard',
                  'columnpath'             => 'En cours',
                  'logedtime'              => 0
                }
              ]
      refreshed_tasks = [tasks.first.merge('title' => 'Write API specifications')]
      api = Minitest::Mock.new
      api.expect :get_all_tasks, tasks, [2]
      api.expect :get_all_tasks, refreshed_tasks, [2]
      api.expect :get_board_structure, {'columns' => [], 'lanes' => []}, [2]
      board = Kanbanize::Board.new(api, {'id' => '2', 'name' => 'Test board'})
      board.tasks.first.title.must_equal "Write Api specs"
      board.tasks!.first.title.must_equal "Write API specifications"
      api.verify
    end
  end

  describe '#version' do
    describe 'with a valid version name' do
      it 'returns an array of tasks' do
        subject.version('20130612').must_be_instance_of Array
        subject.version('20130612').first.must_be_instance_of Kanbanize::Task
      end

      it 'returns the tasks from the specified archived version' do
        subject.version('20130612').first.id.must_equal 7
        subject.version('20130612').first.title.must_equal 'Test'
        subject.version('20130612').last.id.must_equal 11
        subject.version('20130612').last.title.must_equal 'dfh'
      end
    end

    describe 'with an invalid version name' do
      it 'returns nil' do
        subject.version('inexistant').must_equal nil
      end
    end
  end

  describe '#[]' do
    describe 'with a valid column name' do
      it 'returns a Column object' do
        subject['Suivants'].must_be_instance_of Kanbanize::Board::Column
      end

      it 'returns the specified column' do
        subject['Suivants'].name.must_equal 'Suivants'
        subject['Suivants'].position.must_equal 0
      end
    end

    describe 'with an invalid column name' do
      it 'returns nil' do
        subject['inexistant'].must_equal nil
      end
    end

    describe 'with a valid column position' do
      it 'returns a Column object' do
        subject[0].must_be_instance_of Kanbanize::Board::Column
      end

      it 'returns the specified column' do
        subject[0].name.must_equal 'Suivants'
        subject[0].position.must_equal 0
      end
    end

    describe 'with an invalid column position' do
      it 'returns nil' do
        subject[60].must_equal nil
      end
    end
  end

  describe '#column' do
    it 'behaves like #[]' do
      subject.column('Suivants').must_equal subject['Suivants']
      subject.column('inexistant').must_equal subject['inexistant']
      subject.column(0).must_equal subject[0]
      subject.column(60).must_equal subject[60]
    end
  end

  describe '#lane' do
    describe 'with a valid lane name' do
      it 'returns a Lane object' do
        subject.lane('Urgent').must_be_instance_of Kanbanize::Board::Lane
      end

      it 'returns the specified lane' do
        subject.lane('Urgent').name.must_equal 'Urgent'
      end
    end

    describe 'with an invalid lane name' do
      it 'returns nil' do
        subject['inexistant'].must_equal nil
      end
    end
  end
end
