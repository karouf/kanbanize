require 'httparty'

module Kanbanize
  class API
    include HTTParty

    base_uri 'http://kanbanize.com/index.php/api/kanbanize'

    format :json

    def initialize(apikey)
      self.class.headers 'apikey' => apikey

      if ENV['http_proxy'].nil?
        self.class.http_proxy
      else
        proxy = ENV['http_proxy'].match(/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/)[4]

        host, port = proxy.split(':')
        self.class.http_proxy host, port.to_i
      end
    end

    def get_projects_and_boards
      self.class.post('/get_projects_and_boards/format/json')
    end

    def get_board_structure(board_id)
      self.class.post("/get_board_structure/boardid/#{board_id}/format/json")
    end

    def get_board_settings(board_id)
      self.class.post("/get_board_settings/boardid/#{board_id}/format/json")
    end

    def get_board_activities(board_id, from, to, options = {})
      url = "/get_board_activities/boardid/#{board_id}/fromdate/#{from}/todate/#{to}"

      url += "/page/#{options[:page]}" if options[:page]
      url += "/resultsperpage/#{options[:results]}" if options[:results]
      url += "/author/#{options[:author]}" if options[:author]
      url += "/eventtype/#{options[:events]}" if options[:events]

      url += "/format/json"

      self.class.post(url)
    end
  end
end
