require_relative '../../spec_helper'

describe Kanbanize::Project do
  it 'gives access to its id' do
    Kanbanize::Project.new({}).must_respond_to :id
  end

  it 'gives access to its name' do
    Kanbanize::Project.new({}).must_respond_to :name
  end

  it 'gives access to its boards' do
    Kanbanize::Project.new({}).must_respond_to :boards
  end

  it 'sets its id from the data provided' do
    Kanbanize::Project.new({'id' => '1'}).id.must_equal 1
  end

  it 'sets its name from the data provided' do
    Kanbanize::Project.new({'name' => 1}).name.must_equal 1
  end

  it 'sets its boards from the data provided' do
    Kanbanize::Project.new({'boards' => [{'name' => 'Testers board', 'id' => '1'}]}).boards.count.must_equal 1
  end

  describe '#boards' do
    it 'returns an array' do
      Kanbanize::Project.new({'boards' => [{'name' => 'Testers board', 'id' => '1'}]}).boards.must_be_instance_of Array
    end

    it 'returns an array of Board objects' do
      Kanbanize::Project.new({'boards' => [{'name' => 'Testers board', 'id' => '1'}]}).boards.first.must_be_instance_of Kanbanize::Board
    end

    it 'returns Board objects belonging to that Project' do
      Kanbanize::Project.new({'boards' => [{'name' => 'Testers board', 'id' => '1'}]}).boards.first.name.must_equal 'Testers board'
    end
  end
end
