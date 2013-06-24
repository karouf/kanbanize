require_relative '../../spec_helper'


describe Kanbanize::API do

  it 'uses the Kanbanize API endpoint as its base URI' do
    Kanbanize::API.base_uri.must_equal 'http://kanbanize.com/index.php/api/kanbanize'
  end

  it 'parses the API reponses as XML' do
    Kanbanize::API.default_options[:format].must_equal :xml
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
end

