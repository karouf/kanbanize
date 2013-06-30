module Kanbanize
  class Project
    attr_reader :id, :name

    def initialize(data)
      @id = data['id'].to_i
      @name = data['name']
    end
  end
end
