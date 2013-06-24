require 'httparty'

module Kanbanize
  class API
    include HTTParty

    base_uri 'http://kanbanize.com/index.php/api/kanbanize'

    def initialize(apikey)
      self.class.headers 'apikey' => apikey
    end
  end
end
