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
  end
end
