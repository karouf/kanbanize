module Kanbanize
  class Task

    attr_reader :id, :title

    def initialize (attributes)
      raise ArgumentError unless attributes['taskid']

      @id = attributes['taskid'].to_i
      @title = attributes['title']
    end
  end
end
