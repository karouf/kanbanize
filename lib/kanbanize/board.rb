module Kanbanize
  class Board

    # @return [Integer] the id of the board
    attr_reader :id
    
    # @return [String] the name of the board
    attr_reader :name

    # @param api [Kanbanize::API] the API object the board attributes are retrieved from
    # @param attributes [Hash] the attributes of the board to be created
    # @raise [ArgumentError] if the id of the board is not specified
    # @raise [ArgumentError] if the name of the board is not specified
    def initialize(api, attributes)
      raise ArgumentError unless attributes['id']
      raise ArgumentError unless attributes['name']

      @api = api

      @id = attributes['id'].to_i if attributes['id']
      @name = attributes['name']

      initialize_structure
    end

    # Get the tasks currently on the board and cache them.
    # If they have already been cached, returns them without
    # fetching from the API.
    #
    # @return [Array<Kanbanize::Task>]
    def tasks
      @tasks || tasks!
    end

    # Get the tasks currently on the board, fresh from the API.
    #
    # @return [Array<Kanbanize::Task>]
    def tasks!
      @tasks = @api.get_all_tasks(@id).map{|t| Task.new(self, t)}
    end

    # Get the tasks archived in a specified version.
    #
    # @param name [String] the name of the version to be fetched
    # @return [Array<Kanbanize::Task>] if the version can be fetched
    # @return [nil] if the version doesn't exist
    def version(name)
      tasks = @api.get_all_tasks(@id, :archive => true, :version => name)
      if tasks
        return tasks['task'].map{|t| Task.new(self, t)}
      else
        return nil
      end
    end

    # Get the specified column from the board
    #
    # @param arg [String, Integer] the name or the index of the column
    # @return [Kanbanize::Column] the specified column
    def [](arg)
      @columns[arg] || @columns.select{|k,v| v.position == arg}.values.first
    end
    alias_method :column, :[]

    # Get the specified lane from the board
    #
    # @param name [String] the name of the lane
    # @return [Kanbanize::Lane] the specified lane
    def lane(name)
      @lanes[name]
    end

    private

    # Initialize the structure of the board by fetching it from the API
    # and populating intance variables with columns and lanes
    def initialize_structure
      structure = @api.get_board_structure(@id)

      @columns = {}
      structure['columns'].each do |attributes|
        column = Column.new(self, attributes)
        @columns[column.name] = column
      end

      @lanes = {}
      structure['lanes'].each do |attributes|
        lane = Lane.new(self, attributes)
        @lanes[lane.name] = lane
      end
    end
  end
end
