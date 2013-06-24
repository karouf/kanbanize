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
