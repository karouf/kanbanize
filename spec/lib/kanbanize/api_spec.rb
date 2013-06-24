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
end

