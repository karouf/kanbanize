module Kanbanize
  class Board
    class Lane
      attr_reader :name

      def initialize(board, attributes)
        @board = board
        @name = attributes['lcname']
      end

      def tasks
        @tasks ||= tasks!
      end

      def tasks!
        @board.tasks!.select{|t| t.lane == self}
      end
    end
  end
end
