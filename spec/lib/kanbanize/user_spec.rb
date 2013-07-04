require_relative '../../spec_helper'

describe Kanbanize::User do

  before do
    VCR.insert_cassette 'user', :record => :new_episodes
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

    it 'gives access to its username' do
      Kanbanize::User.new(KANBANIZE_API_KEY).username.must_equal nil
    end

    it 'gives access to its real name' do
      Kanbanize::User.new(KANBANIZE_API_KEY).realname.must_equal nil
    end

    it 'gives access to its email address' do
      Kanbanize::User.new(KANBANIZE_API_KEY).email.must_equal nil
    end

    it 'gives access to its company name' do
      Kanbanize::User.new(KANBANIZE_API_KEY).company.must_equal nil
    end

    it 'gives access to its timezone' do
      Kanbanize::User.new(KANBANIZE_API_KEY).timezone.must_equal nil
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

  describe '#projects' do
    subject { Kanbanize::User.new(KANBANIZE_API_KEY).projects }

    it 'gives access to its projects' do
      Kanbanize::User.new(KANBANIZE_API_KEY).must_respond_to :projects
    end

    it 'returns an array of projects' do
      subject.must_be_instance_of Array
      subject.first.must_be_instance_of Kanbanize::Project
    end

    it 'gets its projects from Kanbanize' do
      subject.count.must_equal 1
      subject.first.id.must_equal 1
      subject.first.name.must_equal 'My First Kanban Project'
    end
  end
end
