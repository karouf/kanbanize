require_relative '../../spec_helper'


describe Kanbanize::API do

  it 'uses the Kanbanize API endpoint as its base URI' do
    Kanbanize::API.base_uri.must_equal 'http://kanbanize.com/index.php/api/kanbanize'
  end

  describe 'initialize' do
    it "sets the 'apikey' HTTP header with the API key submitted" do
      api = Kanbanize::API.new('testapikey')
      api.class.default_options[:headers]['apikey'].must_equal 'testapikey'
    end
  end
end

