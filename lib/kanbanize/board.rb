module Kanbanize
  class Board
    attr_reader :id, :name

    def initialize(data)
      raise ArgumentError unless data['id']
      raise ArgumentError unless data['name']

      @id = data['id'].to_i if data['id']
      @name = data['name']
    end
  end
end
