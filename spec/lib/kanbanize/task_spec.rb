require_relative '../../spec_helper'

describe Kanbanize::Task do
  before do
    VCR.insert_cassette 'task', :record => :new_episodes
  end

  after do
    VCR.eject_cassette
  end

  let(:api) { Kanbanize::API.new(KANBANIZE_API_KEY) }
  let(:board) { Kanbanize::Board.new(api, {'id' => '2', 'name' => 'Test board'}) }
  let(:attributes) do
    { 'taskid'                  => '7',
      'columnname'              => 'En cours',
      'lanename'                => 'Standard',
      'title'                   => 'Write API specs',
      'position'                => '0',
      'type'                    => 'Feature request',
      'assignee'                => 'karouf',
      'description'             => 'Make this lib behave',
      'color'                   => '#b3b340',
      'priority'                => 'Average',
      'size'                    => nil,
      'deadlineoriginalformat'  => nil,
      'extlink'                 => nil,
      'tags'                    => nil,
      'leadtime'                => 19,
      'blocked'                 => '0',
      'blockedreason'           => nil,
      'logedtime'               => 0
    }
  end

  subject { Kanbanize::Task.new(board, attributes) }

  it 'gives access to its id' do
    subject.must_respond_to :id
  end

  it 'gives access to its title' do
    subject.must_respond_to :title
  end

  it 'gives access to its column' do
    subject.must_respond_to :column
  end

  it 'gives access to its lane' do
    subject.must_respond_to :lane
  end

  it 'gives access to its position' do
    subject.must_respond_to :position
  end

  it 'gives access to its type' do
    subject.must_respond_to :type
  end

  it 'gives access to its assignee' do
    subject.must_respond_to :assignee
  end

  it 'gives access to its description' do
    subject.must_respond_to :description
  end

  it 'gives access to its color' do
    subject.must_respond_to :color
  end

  it 'gives access to its priority' do
    subject.must_respond_to :priority
  end

  it 'gives access to its size' do
    subject.must_respond_to :size
  end

  it 'gives access to its deadline' do
    subject.must_respond_to :deadline
  end

  it 'gives access to its tags' do
    subject.must_respond_to :tags
  end

  it 'gives access to its lead time' do
    subject.must_respond_to :lead_time
  end

  it 'gives access to its block status' do
    subject.must_respond_to :blocked?
  end

  it 'gives access to its block reason' do
    subject.must_respond_to :block_reason
  end

  it 'gives access to its logged time' do
    subject.must_respond_to :logged_time
  end

  describe '#initialize' do
    describe 'with the only required attributes' do
      it 'sets the id from the attributes provided' do
        Kanbanize::Task.new(board, {'taskid' => '7', 'columnname' => 'En cours', 'lanename' => 'Standard'}).id.must_equal 7
      end

      it 'sets the column from the attributes provided' do
        Kanbanize::Task.new(board, {'taskid' => '7', 'columnname' => 'En cours', 'lanename' => 'Standard'}).column.name.must_equal 'En cours'
      end

      it 'sets the lane from the attributes provided' do
        Kanbanize::Task.new(board, {'taskid' => '7', 'columnname' => 'En cours', 'lanename' => 'Standard'}).lane.name.must_equal 'Standard'
      end

      it 'sets all other attributes to nil' do
        task = Kanbanize::Task.new(board, {'taskid' => '7', 'columnname' => 'En cours', 'lanename' => 'Standard'})
        task.title.must_be_nil
        task.block_reason.must_be_nil
        task.type.must_be_nil
        task.assignee.must_be_nil
        task.color.must_be_nil
        task.description.must_be_nil
        task.priority.must_be_nil
        task.position.must_be_nil
        task.blocked?.must_be_nil
        task.lead_time.must_be_nil
        task.logged_time.must_be_nil
        task.deadline.must_be_nil
        task.size.must_be_nil
      end
    end

    describe 'with valid attributes' do
      it 'sets the id from the attributes provided' do
        subject.id.must_equal 7
      end

      it 'sets the title from the attributes provided' do
        subject.title.must_equal 'Write API specs'
      end

      it 'sets the position from the attributes provided' do
        subject.position.must_equal 0
      end

      it 'sets the type from the attributes provided' do
        subject.type.must_equal 'Feature request'
      end

      it 'sets the assignee from the attributes provided' do
        subject.assignee.must_equal 'karouf'
      end

      it 'sets the description from the attributes provided' do
        subject.description.must_equal 'Make this lib behave'
      end

      it 'sets the color from the attributes provided' do
        subject.color.must_equal '#b3b340'
      end

      it 'sets the priority from the attributes provided' do
        attrs = attributes.merge({'priority' => 'Low'})
        Kanbanize::Task.new(board, attrs).priority.must_equal :low
        attrs = attributes.merge({'priority' => 'Average'})
        Kanbanize::Task.new(board, attrs).priority.must_equal :average
        attrs = attributes.merge({'priority' => 'High'})
        Kanbanize::Task.new(board, attrs).priority.must_equal :high
      end

      it 'sets the size from the attributes provided' do
        subject.size.must_equal nil
      end

      it 'sets the deadline from the attributes provided' do
        attrs = attributes.merge({'deadlineoriginalformat' => nil})
        Kanbanize::Task.new(board, attrs).deadline.must_equal nil
        attrs = attributes.merge({'deadlineoriginalformat' => '2013-12-31'})
        Kanbanize::Task.new(board, attrs).deadline.must_equal Date.new(2013, 12, 31)
      end

      it 'sets the tags from the attributes provided' do
        attrs = attributes.merge({'tags' => ''})
        Kanbanize::Task.new(board, attrs).tags.must_equal []
        attrs = attributes.merge({'tags' => 'list of tags'})
        Kanbanize::Task.new(board, attrs).tags.must_equal ['list', 'of', 'tags']
      end

      it 'sets the lead time from the attributes provided' do
        subject.lead_time.must_equal 19
      end

      it 'sets the block status from the attributes provided' do
        attrs = attributes.merge({'blocked' => '0'})
        Kanbanize::Task.new(board, attrs).blocked?.must_equal false
        attrs = attributes.merge({'blocked' => '1'})
        Kanbanize::Task.new(board, attrs).blocked?.must_equal true
      end

      it 'sets the block reason from the attributes provided' do
        subject.block_reason.must_equal nil
        attrs = attributes.merge({'blockedreason' => 'Some reason'})
        Kanbanize::Task.new(board, attrs).block_reason.must_equal 'Some reason'
      end

      it 'sets the logged time from the attributes provided' do
        subject.logged_time.must_equal 0
      end
    end

    describe 'with invalid attributes' do
      it 'raises an ArgumentError if no id is provided' do
        lambda{ Kanbanize::Task.new(board, {'columnname' => 'En cours', 'lanename' => 'Standard'}) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if no column name is provided' do
        lambda{ Kanbanize::Task.new(board, {'taskid' => '7', 'lanename' => 'Standard'}) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if no lane name is provided' do
        lambda{ Kanbanize::Task.new(board, {'taskid' => '7', 'columnname' => 'En cours'}) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if the id is not an integer' do
        attrs = attributes.merge({'taskid' => 'a'})
        lambda { Kanbanize::Task.new(board, attrs) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if the priority is not "Low", "Average" or "High"' do
        attrs = attributes.merge({'priority' => 'a'})
        lambda { Kanbanize::Task.new(board, attrs) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if the position is not an integer' do
        attrs = attributes.merge({'position' => 'a'})
        lambda { Kanbanize::Task.new(board, attrs) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if block status is neither 0 or 1' do
        attrs = attributes.merge({'blocked' => 'a'})
        lambda { Kanbanize::Task.new(board, attrs) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if the lead time is not an integer' do
        attrs = attributes.merge({'leadtime' => 'a'})
        lambda { Kanbanize::Task.new(board, attrs) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if the logged time is not an integer' do
        attrs = attributes.merge({'logedtime' => 'a'})
        lambda { Kanbanize::Task.new(board, attrs) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if the deadline is in the wrong format' do
        attrs = attributes.merge({'deadlineoriginalformat' => '20131231'})
        lambda { Kanbanize::Task.new(board, attrs) }.must_raise ArgumentError
      end
    end
  end
end
