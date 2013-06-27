require 'httparty'
require 'uri'

module Kanbanize
  class API
    include HTTParty

    base_uri 'http://kanbanize.com/index.php/api/kanbanize'

    format :json

    attr_reader :apikey

    def initialize(apikey = nil )
      set_apikey(apikey)
      set_proxy
    end

    def login(email, pass)
      hash = self.class.post("/login/email/#{uri_encode(email)}/pass/#{uri_encode(pass)}/format/json")

      set_apikey(hash['apikey'])

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

    def get_all_tasks(board_id, options = {})
      raise ArgumentError if options[:from] && !options[:archive]
      raise ArgumentError if options[:to] && !options[:archive]
      raise ArgumentError if options[:version] && !options[:archive]
      raise ArgumentError if options[:page] && !options[:archive]
      raise ArgumentError if options[:page] && !options[:page].kind_of?(Integer)
      raise ArgumentError if options[:page] && (options[:page] < 1)

      uri = "/get_all_tasks/boardid/#{board_id}"
      uri += '/subtasks/yes' if options[:subtasks]
      uri += '/container/archive' if options[:archive]
      uri += "/fromdate/#{options[:from]}" if options[:from]
      uri += "/todate/#{options[:to]}" if options[:to]
      uri += "/version/#{options[:version]}" if options[:version]
      uri += "/page/#{options[:page]}" if options[:page]
      uri += "/format/json"

      post(uri)
    end

    private
    def post(uri)
      self.class.post(uri, :headers => {'apikey' => @apikey})
    end

    def set_proxy
      if ENV['http_proxy'].nil?
        self.class.http_proxy
      else
        proxy = ENV['http_proxy'].match(/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/)[4]

        host, port = proxy.split(':')
        self.class.http_proxy host, port.to_i
      end
    end

    def uri_encode(string)
      URI.escape(string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end

    def set_apikey(apikey)
      @apikey = apikey if apikey
    end
  end
end
