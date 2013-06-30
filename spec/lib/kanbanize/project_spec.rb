require_relative '../../spec_helper'

describe Kanbanize::Project do
  it 'gives access to its id' do
    Kanbanize::Project.new({}).must_respond_to :id
  end

  it 'gives access to its name' do
    Kanbanize::Project.new({}).must_respond_to :name
  end

  it 'sets its id from the data provided' do
    Kanbanize::Project.new({'id' => 1}).id.must_equal 1
  end

  it 'sets its name from the data provided' do
    Kanbanize::Project.new({'name' => 1}).name.must_equal 1
  end
end
