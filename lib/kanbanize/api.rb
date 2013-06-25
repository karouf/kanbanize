require 'httparty'
require 'uri'

module Kanbanize
  class API
    include HTTParty

    base_uri 'http://kanbanize.com/index.php/api/kanbanize'

    format :json

    attr_reader :apikey

    def initialize(apikey = nil )
      @apikey = apikey if apikey

      if ENV['http_proxy'].nil?
        self.class.http_proxy
      else
        proxy = ENV['http_proxy'].match(/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/)[4]

        host, port = proxy.split(':')
        self.class.http_proxy host, port.to_i
      end
    end

    def login(email, pass)
      email = URI.escape(email, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
      pass = URI.escape(pass, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

      hash = self.class.post("/login/email/#{email}/pass/#{pass}/format/json")

      @apikey = hash['apikey']

      return hash
    end

    def get_projects_and_boards
      post('/get_projects_and_boards/format/json')
    end

    def get_board_structure(board_id)
      post("/get_board_structure/boardid/#{board_id}/format/json")
    end

    def get_board_settings(board_id)
      post("/get_board_settings/boardid/#{board_id}/format/json")
    end

    def get_board_activities(board_id, from, to, options = {})
      uri = "/get_board_activities/boardid/#{board_id}/fromdate/#{from}/todate/#{to}"
      uri += "/page/#{options[:page]}" if options[:page]
      uri += "/resultsperpage/#{options[:results]}" if options[:results]
      uri += "/author/#{options[:author]}" if options[:author]
      uri += "/eventtype/#{options[:events]}" if options[:events]
      uri += "/format/json"

      post(uri)
    end

    private
    def post(uri)
      self.class.post(uri, :headers => {'apikey' => @apikey})
    end
  end
end
