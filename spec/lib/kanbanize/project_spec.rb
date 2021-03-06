require_relative '../../spec_helper'

describe Kanbanize::Project do
  before do
    VCR.insert_cassette 'project', :record => :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  let(:api) { Kanbanize::API.new(KANBANIZE_API_KEY)}
  let(:projects) { api.get_projects_and_boards['projects'] }
  subject { Kanbanize::Project.new(api, projects.first) }

  it 'gives access to its id' do
    subject.must_respond_to :id
  end

  it 'gives access to its name' do
    subject.must_respond_to :name
  end

  it 'gives access to its boards' do
    subject.must_respond_to :boards
  end

  describe '#initialize' do
    describe 'with valid data' do
      it 'sets its id from the data provided' do
        subject.id.must_equal 1
      end

      it 'sets its name from the data provided' do
        subject.name.must_equal 'My First Kanban Project'
      end

      it 'sets its boards from the data provided' do
        subject.boards.count.must_equal 2
      end

      it 'sets its boards to an empty array if boards are not provided' do
        Kanbanize::Project.new(api, {'id' => '1', 'name' => 'Test project', 'boards' => []}).boards.must_be_empty
      end
    end

    describe 'with invalid data' do
      it 'raises an ArgumentError if no id is provided' do
        lambda do
          Kanbanize::Project.new({'name' => 'Test project', 'boards' => ['id' => '1', 'name' => 'Testers board']})
        end.must_raise ArgumentError
      end

      it 'raises an ArgumentError if no name is provided' do
        lambda do
          Kanbanize::Project.new({'id' => '1', 'boards' => ['id' => '1', 'name' => 'Testers board']})
        end.must_raise ArgumentError
      end
    end
  end

  describe '#boards' do
    it 'returns an array' do
      subject.boards.must_be_instance_of Array
    end

    it 'returns an array of Board objects' do
      subject.boards.first.must_be_instance_of Kanbanize::Board
    end

    it 'returns Board objects belonging to that Project' do
      subject.boards.first.name.must_equal 'Test'
    end
  end
end
