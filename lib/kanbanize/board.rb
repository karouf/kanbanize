module Kanbanize
  class Board
    attr_reader :id, :name

    def initialize(api, attributes)
      raise ArgumentError unless attributes['id']
      raise ArgumentError unless attributes['name']

      @api = api

      @id = attributes['id'].to_i if attributes['id']
      @name = attributes['name']

      initialize_structure
    end

    def tasks
      @tasks || tasks!
    end

    def tasks!
      @tasks = @api.get_all_tasks(@id).map{|t| Task.new(t)}
    end

    def version(name)
      tasks = @api.get_all_tasks(@id, :archive => true, :version => name)
      if tasks
        return tasks['task'].map{|t| Task.new(t)}
      else
        return nil
      end
    end

    def [](arg)
      @columns[arg] || @columns.select{|k,v| v.position == arg}.values.first
    end
    alias_method :column, :[]

    private
    def initialize_structure
      @columns = {}
      @api.get_board_structure(@id)['columns'].each do |attributes|
        column = Column.new(attributes)
        @columns[column.name] = column
      end
    end
  end
end
