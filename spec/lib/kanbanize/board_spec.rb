require_relative '../../spec_helper'

describe Kanbanize::Board do

  subject { Kanbanize::Board.new({'id' => '1', 'name' => 'Test board'}) }

  it 'gives access to its id' do
    subject.must_respond_to :id
  end

  it 'gives access to its name' do
    subject.must_respond_to :name
  end

  describe '#initialize' do
    describe 'with valid data' do
      it 'sets the board id from the data provided' do
        subject.id.must_equal 1
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
        lambda{ Kanbanize::Board.new({'id' => '1'}) }.must_raise ArgumentError
      end
    end
  end
end
