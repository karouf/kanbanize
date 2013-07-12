module Kanbanize
  class Board
    class Column
      attr_reader :name, :position, :board

      def initialize(board, attributes)
        @board = board
        @name = attributes['lcname']
        @position = attributes['position'].to_i
      end

      def ==(other)
        @name == other.name && @position == other.position
      end

      def lane(name)
        Cell.new(self, @board.lane(name))
      end
      alias_method :[], :lane

      def tasks
        @tasks ||= @board.tasks.select{|t| t.column == self}
      end
    end
  end
end
