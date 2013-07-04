require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'minitest/reporters'
require 'webmock/minitest'
require 'vcr'

require_relative '../lib/kanbanize'

MiniTest::Reporters.use! MiniTest::Reporters::SpecReporter.new

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end

KANBANIZE_API_KEY = ENV['KANBANIZE_API_KEY'] || 'testapikey'
KANBANIZE_EMAIL = ENV['KANBANIZE_EMAIL'] || 'test@testers.com'
KANBANIZE_PASS = ENV['KANBANIZE_PASS'] || 'test'
