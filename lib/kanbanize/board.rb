module Kanbanize
  class Board
    attr_reader :id, :name

    def initialize(api, attributes)
      raise ArgumentError unless attributes['id']
      raise ArgumentError unless attributes['name']

      @api = api

      @id = attributes['id'].to_i if attributes['id']
      @name = attributes['name']
    end

    def tasks
      @tasks || tasks!
    end

    def tasks!
      @tasks = @api.get_all_tasks(@id).map{|t| Task.new(t)}
    end
  end
end
