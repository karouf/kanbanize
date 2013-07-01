module Kanbanize
  class Project
    attr_reader :id, :name, :boards

    def initialize(data)
      raise ArgumentError unless data['id']
      raise ArgumentError unless data['name']

      @id = data['id'].to_i
      @name = data['name']

      @boards = []
      if data['boards']
        data['boards'].each do |board|
          @boards << Board.new(board)
        end
      end
    end
  end
end
