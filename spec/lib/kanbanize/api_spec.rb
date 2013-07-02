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
    before do
      @http_proxy = ENV['http_proxy']
    end

    after do
      ENV['http_proxy'] = @http_proxy
    end

    subject { Kanbanize::API.new(KANBANIZE_API_KEY) }

    it "sets the 'apikey' HTTP header with the API key submitted" do
      subject.apikey.must_equal 'testapikey'
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

  describe '#login' do
    before do
      VCR.insert_cassette 'login', :record => :new_episodes
    end

    after do
      VCR.eject_cassette
    end

    subject { Kanbanize::API.new }

    let(:login) do
      email = 'test@testers.com'
      pass  = 'test'
      subject.login(email, pass)
    end

    it 'returns a hash' do
      login.must_be_instance_of Hash
    end

    it 'returns your email address' do
      login['email'].must_equal 'test@testers.com'
    end

    it 'returns your username' do
      login['username'].must_equal 'test'
    end

    it 'returns your real name' do
      login['realname'].must_equal 'Testy McTest'
    end

    it 'returns your company name' do
      login['companyname'].must_equal 'Testers Inc.'
    end

    it 'returns your timezone' do
      login['timezone'].must_equal '+00:00'
    end

    it 'returns your API key' do
      login['apikey'].must_equal 'testapikey'
    end

    it 'sets the API key to be used' do
      login
      subject.apikey.must_equal 'testapikey'
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

  describe '#get_all_tasks' do
    before do
      VCR.insert_cassette 'get_all_tasks', :record => :new_episodes
    end

    after do
      VCR.eject_cassette
    end

    describe 'by default' do

      subject { Kanbanize::API.new(KANBANIZE_API_KEY).get_all_tasks(2) }

      it 'performs the HTTP request' do
        subject
        assert_requested :post, 'http://kanbanize.com/index.php/api/kanbanize/get_all_tasks/boardid/2/format/json'
      end

      it 'returns an array of tasks' do
        subject.must_be_instance_of Array
      end

      it 'returns the tasks data' do
        subject[0]['taskid'].to_i.must_equal 7
      end
    end

    describe 'with subtasks requested' do

      subject do
        options = {:subtasks => true}
        Kanbanize::API.new(KANBANIZE_API_KEY).get_all_tasks(2, options)
      end

      it 'performs the HTTP request' do
        subject
        assert_requested :post, 'http://kanbanize.com/index.php/api/kanbanize/get_all_tasks/boardid/2/subtasks/yes/format/json'
      end

      it 'returns an array of tasks' do
        subject.must_be_instance_of Array
      end

      it 'returns the tasks data' do
        subject[0]['taskid'].to_i.must_equal 7
      end

      it 'returns an array of subtasks for each task' do
        subject[0]['subtaskdetails'].must_be_instance_of Array
      end

      it 'returns the subtasks data' do
        subject[0]['subtaskdetails'][0]['subtaskid'].to_i.must_equal 42
      end
    end

    describe 'with archive requested' do

      subject do
        options = {:archive => true}
        Kanbanize::API.new(KANBANIZE_API_KEY).get_all_tasks(2, options)
      end

      it 'performs the HTTP request' do
        subject
        assert_requested :post, 'http://kanbanize.com/index.php/api/kanbanize/get_all_tasks/boardid/2/container/archive/format/json'
      end

      it 'returns a hash' do
        subject.must_be_instance_of Hash
      end

      it 'returns the number of tasks' do
        subject['numberoftasks'].to_i.must_equal 5
      end

      it 'returns the current page' do
        subject['page'].to_i.must_equal 1
      end

      it 'returns the number of tasks page' do
        subject['tasksperpage'].to_i.must_equal 30
      end

      it 'returns an array of tasks' do
        subject['task'].must_be_instance_of Array
      end

      it 'returns the tasks data' do
        subject['task'][0]['taskid'].to_i.must_equal 7
      end
    end

    describe 'with a from date specified' do
      describe 'with the archive requested' do

        subject do
          options = {:archive => true, :from => Date.new(2013, 06, 14)}
          Kanbanize::API.new(KANBANIZE_API_KEY).get_all_tasks(2, options)
        end

        it 'performs the HTTP request' do
          subject
          assert_requested :post, 'http://kanbanize.com/index.php/api/kanbanize/get_all_tasks/boardid/2/container/archive/fromdate/2013-06-14/format/json'
        end

        it 'returns a hash' do
          subject.must_be_instance_of Hash
        end

        it 'returns the number of tasks' do
          subject['numberoftasks'].to_i.must_equal 0
        end

        it 'returns the current page' do
          subject['page'].to_i.must_equal 1
        end

        it 'returns the number of tasks page' do
          subject['tasksperpage'].to_i.must_equal 30
        end

        it 'returns an array of tasks' do
          subject['task'].must_be_instance_of Array
        end

        it 'returns the tasks data' do
          subject['task'].must_be_empty
        end
      end
    end

    describe 'with an archive to date specified' do
      describe 'with the archive requested' do

        subject do
          options = {:archive => true, :to => Date.new(2013, 06, 12)}
          Kanbanize::API.new(KANBANIZE_API_KEY).get_all_tasks(2, options)
        end

        it 'performs the HTTP request' do
          subject
          assert_requested :post, 'http://kanbanize.com/index.php/api/kanbanize/get_all_tasks/boardid/2/container/archive/todate/2013-06-12/format/json'
        end

        it 'returns a hash' do
          subject.must_be_instance_of Hash
        end

        it 'returns the number of tasks' do
          subject['numberoftasks'].to_i.must_equal 0
        end

        it 'returns the current page' do
          subject['page'].to_i.must_equal 1
        end

        it 'returns the number of tasks page' do
          subject['tasksperpage'].to_i.must_equal 30
        end

        it 'returns an array of tasks' do
          subject['task'].must_be_instance_of Array
        end

        it 'returns the tasks data' do
          subject['task'].must_be_empty
        end
      end
    end

    describe 'with archive version specified' do
      describe 'with the archive requested' do

        subject do
          options = {:archive => true, :version => '20130612'}
          Kanbanize::API.new(KANBANIZE_API_KEY).get_all_tasks(2, options)
        end

        it 'performs the HTTP request' do
          subject
          assert_requested :post, 'http://kanbanize.com/index.php/api/kanbanize/get_all_tasks/boardid/2/container/archive/version/20130612/format/json'
        end

        it 'returns a hash' do
          subject.must_be_instance_of Hash
        end

        it 'returns an array of tasks' do
          subject['task'].must_be_instance_of Array
        end

        it 'returns the tasks data' do
          subject['task'][0]['taskid'].to_i.must_equal 7
        end
      end

      describe 'with an incorrect version name' do
        subject do
          options = {:archive => true, :version => '2013061'}
          Kanbanize::API.new(KANBANIZE_API_KEY).get_all_tasks(2, options)
        end

        it 'returns nil' do
          subject.must_be_nil
        end
      end
    end

    describe 'with a page number specified' do
      describe 'with the archive requested' do
        subject do
          options = {:archive => true, :page => 2}
          Kanbanize::API.new(KANBANIZE_API_KEY).get_all_tasks(2, options)
        end

        it 'performs the HTTP request' do
          subject
          assert_requested :post, 'http://kanbanize.com/index.php/api/kanbanize/get_all_tasks/boardid/2/container/archive/page/2/format/json'
        end

        it 'returns a hash' do
          subject.must_be_instance_of Hash
        end

        it 'returns the number of tasks' do
          subject['numberoftasks'].to_i.must_equal 5
        end

        it 'returns the current page' do
          subject['page'].to_i.must_equal 2
        end

        it 'returns the number of tasks page' do
          subject['tasksperpage'].to_i.must_equal 30
        end

        it 'returns an array of tasks' do
          subject['task'].must_be_instance_of Array
        end

        it 'returns the tasks data' do
          subject['task'].must_be_empty
        end
      end

      describe 'with a page argument which is not an integer' do
        subject do
          options = {:archive => true, :page => 'a'}
          Kanbanize::API.new(KANBANIZE_API_KEY).get_all_tasks(2, options)
        end

        it 'raises an exception' do
          lambda{ subject }.must_raise ArgumentError
        end
      end

      describe 'with an page number < 1' do
        subject do
          options = {:archive => true, :page => 0}
          Kanbanize::API.new(KANBANIZE_API_KEY).get_all_tasks(2, options)
        end

        it 'raises an exception' do
          lambda{ subject }.must_raise ArgumentError
        end
      end
    end
  end

  describe '#get_task_details' do
    before do
      VCR.insert_cassette 'get_task_details', :record => :new_episodes
    end

    after do
      VCR.eject_cassette
    end

    subject { Kanbanize::API.new(KANBANIZE_API_KEY) }

    describe 'when proper board and task ids are provided' do
      it 'performs the HTTP request' do
        subject.get_task_details(2, 7)
        assert_requested :post, 'http://kanbanize.com/index.php/api/kanbanize/get_task_details/boardid/2/taskid/7/format/json'
      end

      it 'returns a hash' do
        subject.get_task_details(2, 7).must_be_instance_of Hash
      end

      it 'returns the corresponding task data' do
        subject.get_task_details(2, 7)['title'].must_equal 'Write Api specs'
      end

      describe 'when history is requested' do
        it 'performs the HTTP request' do
          subject.get_task_details(2, 7, :history => true)
          assert_requested :post, 'http://kanbanize.com/index.php/api/kanbanize/get_task_details/boardid/2/taskid/7/history/yes/format/json'
        end

        it 'returns an array of history events' do
          subject.get_task_details(2, 7, :history => true)['historydetails'].must_be_instance_of Array
        end

        it 'returns the history events of the task requested' do
          subject.get_task_details(2, 7, :history => true)['historydetails'][0]['historyid'].to_i.must_equal 88
        end

        describe 'when the type of event is specified' do
          it 'performs the HTTP request' do
            subject.get_task_details(2, 7, :history => true, :event => :comment)
            assert_requested :post, 'http://kanbanize.com/index.php/api/kanbanize/get_task_details/boardid/2/taskid/7/history/yes/event/comment/format/json'
          end

          it 'returns only the history events of the type specified' do
            subject.get_task_details(2, 7, :history => true, :event => :comment)['historydetails'][0]['historyid'].to_i.must_equal 86
          end
        end
      end
    end
  end
end

