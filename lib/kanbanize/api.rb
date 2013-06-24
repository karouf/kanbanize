require 'httparty'

module Kanbanize
  class API
    include HTTParty

    base_uri 'http://kanbanize.com/index.php/api/kanbanize'

    format :xml

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
  end
end
