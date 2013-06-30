module Kanbanize
  class Project
    attr_reader :id, :name

    def initialize(data)
      @id = data['id']
      @name = data['name']
    end
  end
end
