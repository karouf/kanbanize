require_relative '../../../spec_helper'

describe Kanbanize::Board::Lane do

  let(:lane) { Kanbanize::Board::Lane.new({'lcname' => 'Urgent', 'color' => '#d99f9f', 'description' => 'London is burning'}) }

  it 'gives access to its name' do
    lane.must_respond_to :name
  end

  describe '#name' do
    it 'returns the column name' do
      lane.name.must_equal 'Urgent'
    end
  end
end

