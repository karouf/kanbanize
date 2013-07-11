module Kanbanize
  class Board
    class Cell
      attr_reader :column, :lane

      def initialize(column, lane)
        @column = column
        @lane = lane
      end

      def ==(other)
        @column == other.column && @lane == other.lane
      end
    end
  end
end
