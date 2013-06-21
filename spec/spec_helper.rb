require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'minitest/reporters'

require_relative '../lib/kanbanize'

MiniTest::Reporters.use! MiniTest::Reporters::SpecReporter.new
