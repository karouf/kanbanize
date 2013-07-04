require_relative '../../spec_helper'

describe Kanbanize::Task do

  subject { Kanbanize::Task.new({'taskid' => '7', 'title' => 'Write API specs'}) }

  it 'gives access to its id' do
    subject.must_respond_to :id
  end

  it 'gives access to its title' do
    subject.must_respond_to :title
  end

  describe '#initialize' do
    describe 'with valid data' do
      it 'sets the id from the attributes provided' do
        subject.id.must_equal 7
      end

      it 'sets the title from the attributes provided' do
        subject.title.must_equal 'Write API specs'
      end
    end

    describe 'with invalid data' do
      it 'raises an ArgumentError if no id is provided' do
        lambda{ Kanbanize::Task.new({'title' => 'Write Api specs'}) }.must_raise ArgumentError
      end
    end
  end
end
