require_relative '../../spec_helper'


describe Kanbanize::API do

  KANBANIZE_API_KEY = ENV['KANBANIZE_API_KEY'] || 'testapikey'

  it 'uses the Kanbanize API endpoint as its base URI' do
    Kanbanize::API.base_uri.must_equal 'http://kanbanize.com/index.php/api/kanbanize'
  end

  it 'parses the API reponses as JSON' do
    Kanbanize::API.default_options[:format].must_equal :json
  end

  describe '#initialize' do

    subject { Kanbanize::API.new(KANBANIZE_API_KEY) }

    it "sets the 'apikey' HTTP header with the API key submitted" do
      subject.class.default_options[:headers]['apikey'].must_equal 'testapikey'
    end

    it 'uses http_proxy env var to set the proxy to use' do
      ENV['http_proxy'] = "http://localhost:8080"

      subject.class.default_options[:http_proxyaddr].must_equal 'localhost'
      subject.class.default_options[:http_proxyport].must_equal 8080
    end

    it 'uses no proxy if http_proxy env var is not set' do
      ENV.delete('http_proxy')

      subject.class.default_options[:http_proxyaddr].must_be_nil
      subject.class.default_options[:http_proxyport].must_be_nil
    end
  end

  describe '#get_projects_and_boards' do
    before do
      VCR.insert_cassette 'get_projects_and_boards', :record => :new_episodes
    end

    after do
      VCR.eject_cassette
    end

    subject { Kanbanize::API.new(KANBANIZE_API_KEY).get_projects_and_boards }

    it 'returns a hash' do
      subject.must_be_instance_of Hash
    end

    it 'returns all the projects' do
      subject['projects'].must_be_instance_of Array
      subject['projects'].count.must_equal 1
      subject['projects'][0]['id'].to_i.must_equal 1
      subject['projects'][0]['name'].must_equal 'My First Kanban Project'
    end

    it 'returns all the boards' do
      subject['projects'][0]['boards'].must_be_instance_of Array
      subject['projects'][0]['boards'].count.must_equal 2
      subject['projects'][0]['boards'][0]['id'].to_i.must_equal 3
      subject['projects'][0]['boards'][0]['name'].must_equal 'Test'
    end
  end

  describe '#get_board_structure' do
    before do
      VCR.insert_cassette 'get_board_structure', :record => :new_episodes
    end

    after do
      VCR.eject_cassette
    end

    subject { Kanbanize::API.new(KANBANIZE_API_KEY).get_board_structure(2) }

    it 'returns a hash' do
      subject.must_be_instance_of Hash
    end

    it 'returns all the columns of the board' do
      subject['columns'].must_be_instance_of Array
      subject['columns'].count.must_equal 3
      subject['columns'][0]['position'].to_i.must_equal 0
      subject['columns'][0]['lcname'].must_equal 'Suivants'
    end

    it 'returns all the lanes of the board' do
      subject['lanes'].must_be_instance_of Array
      subject['lanes'][0].count.must_equal 3
      subject['lanes'][0]['lcname'].must_equal 'Urgent'
      subject['lanes'][0]['color'].must_equal '#d99f9f'
    end
  end

  describe '#get_board_settings' do
    before do
      VCR.insert_cassette 'get_board_settings', :record => :new_episodes
    end

    after do
      VCR.eject_cassette
    end

    subject { Kanbanize::API.new(KANBANIZE_API_KEY).get_board_settings(2) }

    it 'returns a hash' do
      subject.must_be_instance_of Hash
    end

    it 'returns the usernames of the board members' do
      subject['usernames'].must_be_instance_of Array
      subject['usernames'].count.must_equal 1
      subject['usernames'][0].must_equal 'karouf'
    end

    it 'returns the names of the templates available to this board' do
      subject['templates'].must_be_instance_of Array
      subject['templates'].count.must_equal 3
      subject['templates'][0].must_equal 'Bug'
    end

    it 'returns the names of the types available to this board' do
      subject['types'].must_be_instance_of Array
      subject['types'].count.must_equal 3
      subject['types'][1].must_equal 'Feature request'
    end
  end

  describe '#get_board_activities' do
    before do
      VCR.insert_cassette 'get_board_activities', :record => :new_episodes
    end

    after do
      VCR.eject_cassette
    end

    describe 'by default' do

      subject do
        board_id = 2
        from = Date.new(2013, 06, 23)
        to = Date.new(2013, 06, 26)
        Kanbanize::API.new(KANBANIZE_API_KEY).get_board_activities( board_id,
                                                                    from,
                                                                    to
                                                                  )
      end

      it 'returns a hash' do
        subject.must_be_instance_of Hash
      end

      it 'returns the total number of activities' do
        subject['allactivities'].must_equal 38
      end

      it 'returns the first page' do
        subject['page'].must_equal 1
      end

      it 'returns a max of 30 activities' do
        subject['activities'].count.must_be :<=, 30
      end

      it 'returns the activities' do
        subject['activities'].must_be_instance_of Array
        subject['activities'][0]['author'].must_equal 'karouf'
        subject['activities'][0]['event'].must_equal 'Comment added'
        subject['activities'][0]['taskid'].to_i.must_equal 7
      end

      it 'returns the activities of all authors' do
        authors = []
        subject['activities'].each do |activity|
          if !authors.include? activity['author']
            authors << activity['author']
          end
        end
        authors.count.must_be :>, 1
      end

      it 'returns all types of activities' do
        events = []
        subject['activities'].each do |activity|
          if !events.include? activity['event']
            events << activity['event']
          end
        end
        events.count.must_be :>, 1
      end
    end

    describe 'with the page specified' do

      subject do
        board_id = 2
        from = Date.new(2013, 06, 23)
        to = Date.new(2013, 06, 26)
        Kanbanize::API.new(KANBANIZE_API_KEY).get_board_activities( board_id,
                                                                    from,
                                                                    to,
                                                                    { :page => 2 }
                                                                  )
      end

      it 'returns a hash' do
        subject.must_be_instance_of Hash
      end

      it 'returns the total number of activities' do
        subject['allactivities'].must_equal 38
      end

      it 'returns the specified page' do
        subject['page'].must_equal 2
      end

      it 'returns a max of 30 activities' do
        subject['activities'].count.must_be :<=, 30
      end

      it 'returns the activities' do
        subject['activities'].must_be_instance_of Array
        subject['activities'][0]['author'].must_equal 'karouf'
        subject['activities'][0]['event'].must_equal 'Task created'
        subject['activities'][0]['taskid'].to_i.must_equal 12
      end

      it 'returns the activities of all authors' do
        authors = []
        subject['activities'].each do |activity|
          if !authors.include? activity['author']
            authors << activity['author']
          end
        end
        authors.count.must_be :>, 1
      end

      it 'returns all types of activities' do
        events = []
        subject['activities'].each do |activity|
          if !events.include? activity['event']
            events << activity['event']
          end
        end
        events.count.must_be :>, 1
      end
    end

    describe 'with the number of results per page specified' do

      subject do
        board_id = 2
        from = Date.new(2013, 06, 23)
        to = Date.new(2013, 06, 26)
        Kanbanize::API.new(KANBANIZE_API_KEY).get_board_activities( board_id,
                                                                    from,
                                                                    to,
                                                                    { :results => 2 }
                                                                  )
      end

      it 'returns a hash' do
        subject.must_be_instance_of Hash
      end

      it 'returns the total number of activities' do
        subject['allactivities'].must_equal 38
      end

      it 'returns the first page' do
        subject['page'].must_equal 1
      end

      it 'returns a max of 2 activities' do
        subject['activities'].count.must_be :<=, 2
      end

      it 'returns the activities' do
        subject['activities'].must_be_instance_of Array
        subject['activities'][0]['author'].must_equal 'karouf'
        subject['activities'][0]['event'].must_equal 'Comment added'
        subject['activities'][0]['taskid'].to_i.must_equal 7
      end

      it 'returns the activities of all authors' do
        authors = []
        subject['activities'].each do |activity|
          if !authors.include? activity['author']
            authors << activity['author']
          end
        end
        authors.count.must_be :>, 1
      end

      it 'returns all types of activities' do
        events = []
        subject['activities'].each do |activity|
          if !events.include? activity['event']
            events << activity['event']
          end
        end
        events.count.must_be :>, 1
      end
    end

    describe 'with the author specified' do

      subject do
        board_id = 2
        from = Date.new(2013, 06, 23)
        to = Date.new(2013, 06, 26)
        Kanbanize::API.new(KANBANIZE_API_KEY).get_board_activities( board_id,
                                                                    from,
                                                                    to,
                                                                    { :author => 'tintin' }
                                                                  )
      end

      it 'returns a hash' do
        subject.must_be_instance_of Hash
      end

      it 'returns the total number of activities' do
        subject['allactivities'].must_equal 2
      end

      it 'returns the first page' do
        subject['page'].must_equal 1
      end

      it 'returns a max of 30 activities' do
        subject['activities'].count.must_be :<=, 30
      end

      it 'returns the activities' do
        subject['activities'].must_be_instance_of Array
        subject['activities'][0]['author'].must_equal 'tintin'
        subject['activities'][0]['event'].must_equal 'Comment added'
        subject['activities'][0]['taskid'].to_i.must_equal 7
      end

      it 'returns the activities of "tintin"' do
        authors = []
        subject['activities'].each do |activity|
          if !authors.include? activity['author']
            authors << activity['author']
          end
        end
        authors.count.must_equal 1
        authors.first.must_equal 'tintin'
      end

      it 'returns all types of activities' do
        events = []
        subject['activities'].each do |activity|
          if !events.include? activity['event']
            events << activity['event']
          end
        end
        events.count.must_be :>, 1
      end
    end

    describe 'with the event type specified' do

      subject do
        board_id = 2
        from = Date.new(2013, 06, 23)
        to = Date.new(2013, 06, 26)
        Kanbanize::API.new(KANBANIZE_API_KEY).get_board_activities( board_id,
                                                                    from,
                                                                    to,
                                                                    { :events => 'Comments' }
                                                                  )
      end

      it 'returns a hash' do
        subject.must_be_instance_of Hash
      end

      it 'returns the total number of activities' do
        subject['allactivities'].must_equal 2
      end

      it 'returns the first page' do
        subject['page'].must_equal 1
      end

      it 'returns a max of 30 activities' do
        subject['activities'].count.must_be :<=, 30
      end

      it 'returns the activities' do
        subject['activities'].must_be_instance_of Array
        subject['activities'][0]['author'].must_equal 'karouf'
        subject['activities'][0]['event'].must_equal 'Comment added'
        subject['activities'][0]['taskid'].to_i.must_equal 7
      end

      it 'returns the activities of all authors' do
        authors = []
        subject['activities'].each do |activity|
          if !authors.include? activity['author']
            authors << activity['author']
          end
        end
        authors.count.must_be :>, 1
      end

      it 'returns only activities related to comments' do
        events = []
        subject['activities'].each do |activity|
          if !events.include? activity['event']
            events << activity['event']
          end
        end
        events.count.must_equal 1
        events.first.must_equal 'Comment added'
      end
    end
  end
end

