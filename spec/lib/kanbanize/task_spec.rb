require_relative '../../spec_helper'

describe Kanbanize::Task do

  let(:attributes) do
    { 'taskid'                  => '7',
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

  subject { Kanbanize::Task.new(attributes) }

  it 'gives access to its id' do
    subject.must_respond_to :id
  end

  it 'gives access to its title' do
    subject.must_respond_to :title
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
        Kanbanize::Task.new(attrs).priority.must_equal :low
        attrs = attributes.merge({'priority' => 'Average'})
        Kanbanize::Task.new(attrs).priority.must_equal :average
        attrs = attributes.merge({'priority' => 'High'})
        Kanbanize::Task.new(attrs).priority.must_equal :high
      end

      it 'sets the size from the attributes provided' do
        attrs = attributes.merge({'size' => nil})
        Kanbanize::Task.new(attrs).size.must_equal nil
        attrs = attributes.merge({'size' => 'S'})
        Kanbanize::Task.new(attrs).size.must_equal :S
        attrs = attributes.merge({'size' => 'M'})
        Kanbanize::Task.new(attrs).size.must_equal :M
        attrs = attributes.merge({'size' => 'L'})
        Kanbanize::Task.new(attrs).size.must_equal :L
        attrs = attributes.merge({'size' => 'XL'})
        Kanbanize::Task.new(attrs).size.must_equal :XL
        attrs = attributes.merge({'size' => 'XXL'})
        Kanbanize::Task.new(attrs).size.must_equal :XXL
        attrs = attributes.merge({'size' => 'XXXL'})
        Kanbanize::Task.new(attrs).size.must_equal :XXXL
      end

      it 'sets the deadline from the attributes provided' do
        attrs = attributes.merge({'deadlineoriginalformat' => nil})
        Kanbanize::Task.new(attrs).deadline.must_equal nil
        attrs = attributes.merge({'deadlineoriginalformat' => '2013-12-31'})
        Kanbanize::Task.new(attrs).deadline.must_equal Date.new(2013, 12, 31)
      end

      it 'sets the tags from the attributes provided' do
        attrs = attributes.merge({'tags' => ''})
        Kanbanize::Task.new(attrs).tags.must_equal []
        attrs = attributes.merge({'tags' => 'list of tags'})
        Kanbanize::Task.new(attrs).tags.must_equal ['list', 'of', 'tags']
      end

      it 'sets the lead time from the attributes provided' do
        subject.lead_time.must_equal 19
      end

      it 'sets the block status from the attributes provided' do
        attrs = attributes.merge({'blocked' => '0'})
        Kanbanize::Task.new(attrs).blocked?.must_equal false
        attrs = attributes.merge({'blocked' => '1'})
        Kanbanize::Task.new(attrs).blocked?.must_equal true
      end

      it 'sets the block reason from the attributes provided' do
        subject.block_reason.must_equal nil
        attrs = attributes.merge({'blockedreason' => 'Some reason'})
        Kanbanize::Task.new(attrs).block_reason.must_equal 'Some reason'
      end

      it 'sets the logged time from the attributes provided' do
        subject.logged_time.must_equal 0
      end
    end

    describe 'with invalid attributes' do
      it 'raises an ArgumentError if no id is provided' do
        lambda{ Kanbanize::Task.new({'title' => 'Write Api specs'}) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if the id is not an integer' do
        attrs = attributes.merge({'taskid' => 'a'})
        lambda { Kanbanize::Task.new(attrs) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if the priority is not "Low", "Average" or "High"' do
        attrs = attributes.merge({'priority' => 'a'})
        lambda { Kanbanize::Task.new(attrs) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if the position is not an integer' do
        attrs = attributes.merge({'position' => 'a'})
        lambda { Kanbanize::Task.new(attrs) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if block status is neither 0 or 1' do
        attrs = attributes.merge({'blocked' => 'a'})
        lambda { Kanbanize::Task.new(attrs) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if the lead time is not an integer' do
        attrs = attributes.merge({'leadtime' => 'a'})
        lambda { Kanbanize::Task.new(attrs) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if the logged time is not an integer' do
        attrs = attributes.merge({'logedtime' => 'a'})
        lambda { Kanbanize::Task.new(attrs) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if the deadline is in the wrong format' do
        attrs = attributes.merge({'deadlineoriginalformat' => '20131231'})
        lambda { Kanbanize::Task.new(attrs) }.must_raise ArgumentError
      end

      it 'raises an ArgumentError if the size is not nil, S, M, L, XL, XXL or XXXL' do
        attrs = attributes.merge({'size' => 'a'})
        lambda { Kanbanize::Task.new(attrs) }.must_raise ArgumentError
      end
    end
  end
end
