module Kanbanize
  class Board
    class Cell
      attr_reader :column, :lane, :tasks

      def initialize(column, lane)
        @column = column
        @lane = lane
        @tasks = @column.board.tasks.select{|t| t.column == @column && t.lane == @lane}
      end

      def ==(other)
        @column == other.column && @lane == other.lane
      end
    end
  end
end
