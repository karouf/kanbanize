module Kanbanize
  class Board
    class Lane
      attr_reader :name

      def initialize(attributes)
        @name = attributes['lcname']
      end
    end
  end
end
