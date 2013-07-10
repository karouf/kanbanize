module Kanbanize
  class Board
    class Column
      attr_reader :name, :position

      def initialize(attributes)
        @name = attributes['lcname']
        @position = attributes['position'].to_i
      end

      def ==(other)
        @name == other.name && @position == other.position
      end
    end
  end
end
