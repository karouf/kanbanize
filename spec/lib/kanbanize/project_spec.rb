require_relative '../../spec_helper'

describe Kanbanize::Project do

  subject do
    Kanbanize::Project.new({  'id' => '1',
                              'name' => 'Test project',
                              'boards' => [
                                            'id' => '1',
                                            'name' => 'Testers board'
                                          ]
                            })
  end

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
        subject.name.must_equal 'Test project'
      end

      it 'sets its boards from the data provided' do
        subject.boards.count.must_equal 1
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
      subject.boards.first.name.must_equal 'Testers board'
    end
  end
end
