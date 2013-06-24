require_relative '../../spec_helper'


describe Kanbanize::API do

  KANBANIZE_API_KEY = ENV['KANBANIZE_API_KEY'] || 'testapikey'

  it 'uses the Kanbanize API endpoint as its base URI' do
    Kanbanize::API.base_uri.must_equal 'http://kanbanize.com/index.php/api/kanbanize'
  end

  it 'parses the API reponses as JSON' do
    Kanbanize::API.default_options[:format].must_equal :json
  end

  describe 'initialize' do
    it "sets the 'apikey' HTTP header with the API key submitted" do
      api = Kanbanize::API.new('testapikey')
      api.class.default_options[:headers]['apikey'].must_equal 'testapikey'
    end

    it 'uses http_proxy env var to set the proxy to use' do
      ENV['http_proxy'] = "http://localhost:8080"
      api = Kanbanize::API.new('testapikey')
      api.class.default_options[:http_proxyaddr].must_equal 'localhost'
      api.class.default_options[:http_proxyport].must_equal 8080
    end

    it 'uses no proxy if http_proxy env var is not set' do
      ENV.delete('http_proxy')
      api = Kanbanize::API.new('testapikey')
      api.class.default_options[:http_proxyaddr].must_be_nil
      api.class.default_options[:http_proxyport].must_be_nil
    end
  end

  describe '#get_projects_and_boards' do
    before do
      VCR.insert_cassette 'get_projects_and_boards', :record => :new_episodes
    end

    after do
      VCR.eject_cassette
    end

    subject { Kanbanize::API.new(KANBANIZE_API_KEY) }

    it 'returns a hash' do
      subject.get_projects_and_boards.must_be_instance_of Hash
    end

    it 'returns all the projects' do
      hash = subject.get_projects_and_boards
      hash['projects'].must_be_instance_of Array
      hash['projects'].count.must_equal 1
      hash['projects'][0]['id'].to_i.must_equal 1
      hash['projects'][0]['name'].must_equal 'My First Kanban Project'
    end

    it 'returns all the boards' do
      hash = subject.get_projects_and_boards
      hash['projects'][0]['boards'].must_be_instance_of Array
      hash['projects'][0]['boards'].count.must_equal 2
      hash['projects'][0]['boards'][0]['id'].to_i.must_equal 3
      hash['projects'][0]['boards'][0]['name'].must_equal 'Test'
    end
  end
end

