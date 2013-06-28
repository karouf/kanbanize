require_relative '../../spec_helper'

describe Kanbanize::User do

  KANBANIZE_API_KEY = ENV['KANBANIZE_API_KEY'] || 'testapikey'
  KANBANIZE_EMAIL = ENV['KANBANIZE_EMAIL'] || 'test@testers.com'
  KANBANIZE_PASS = ENV['KANBANIZE_PASS'] || 'test'

  before do
    VCR.insert_cassette 'login', :record => :none
  end

  after do
    VCR.eject_cassette
  end

  describe '#initialize(api_key)' do
    it 'returns a User object' do
      Kanbanize::User.new(KANBANIZE_API_KEY).must_be_instance_of Kanbanize::User
    end
  end

  describe '#initialize(email, pass)' do
    it 'returns a User object' do
      Kanbanize::User.new(KANBANIZE_EMAIL, KANBANIZE_PASS).must_be_instance_of Kanbanize::User
    end
  end

  describe '#initialize with more than 2 arguments' do
    it 'raises an error' do
      lambda { Kanbanize::User.new(1, 2, 3) }.must_raise ArgumentError
    end
  end

  describe 'created with an API key' do
    it 'gives access to its API key' do
      Kanbanize::User.new(KANBANIZE_API_KEY).api_key.must_equal KANBANIZE_API_KEY
    end
  end

  describe 'created with an email and a password' do
    it 'gives access to its API key' do
      Kanbanize::User.new(KANBANIZE_EMAIL, KANBANIZE_PASS).api_key.must_equal KANBANIZE_API_KEY
    end

    it 'gives access to its username' do
      Kanbanize::User.new(KANBANIZE_EMAIL, KANBANIZE_PASS).username.must_equal 'test'
    end

    it 'gives access to its real name' do
      Kanbanize::User.new(KANBANIZE_EMAIL, KANBANIZE_PASS).realname.must_equal 'Testy McTest'
    end

    it 'gives access to its email address' do
      Kanbanize::User.new(KANBANIZE_EMAIL, KANBANIZE_PASS).email.must_equal 'test@testers.com'
    end

    it 'gives access to its company name' do
      Kanbanize::User.new(KANBANIZE_EMAIL, KANBANIZE_PASS).company.must_equal 'Testers Inc.'
    end

    it 'gives access to its timezone' do
      Kanbanize::User.new(KANBANIZE_EMAIL, KANBANIZE_PASS).timezone.must_equal '+00:00'
    end
  end
end
