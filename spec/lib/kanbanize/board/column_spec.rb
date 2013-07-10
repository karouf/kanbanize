require_relative '../../../spec_helper'

describe Kanbanize::Board::Column do

  let(:column) { Kanbanize::Board::Column.new({'position' => '0', 'lcname' => 'Test column', 'description' => 'Column description', 'tasksperrow' => '3'}) }

  it 'gives access to its name' do
    column.must_respond_to :name
  end

  it 'gives access to its position' do
    column.must_respond_to :position
  end

  describe '#name' do
    it 'returns the column name' do
      column.name.must_equal 'Test column'
    end
  end

  describe '#position' do
    it 'returns the column position' do
      column.position.must_equal 0
    end
  end
end
