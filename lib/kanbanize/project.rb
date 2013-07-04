module Kanbanize
  class Project
    attr_reader :id, :name, :boards

    def initialize(api, attributes)
      raise ArgumentError unless attributes['id']
      raise ArgumentError unless attributes['name']

      @id = attributes['id'].to_i
      @name = attributes['name']

      @boards = []
      if attributes['boards']
        attributes['boards'].each do |board|
          @boards << Board.new(api, board)
        end
      end
    end
  end
end
