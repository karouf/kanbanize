module Kanbanize
  class Task

    attr_reader :id, :title, :position, :type, :assignee, :description,
                :color, :priority, :size, :deadline, :tags, :lead_time,
                :block_reason, :logged_time, :column, :lane

    TASK_PRIORITIES = ['Low', 'Average', 'High']

    def initialize (board, attributes)
      @board = board

      set_id(attributes)
      set_column(attributes)
      set_lane(attributes)

      @title = attributes['title']
      @type = attributes['type']
      @assignee = attributes['assignee']
      @description = attributes['description']
      @color = attributes['color']
      @size = attributes['size']
      @tags = attributes['tags'].split(' ') if attributes['tags']
      @block_reason = attributes['blockedreason']

      @lead_time = attributes['leadtime'] ? check_integer(attributes['leadtime']) : nil
      @position = attributes['position'] ? check_integer(attributes['position']) : nil
      @logged_time = attributes['logedtime'] ? check_integer(attributes['logedtime']) : nil

      set_priority(attributes)
      set_block_status(attributes)
      set_deadline(attributes)
    end

    def blocked?
      @blocked
    end

    private
    def set_id(attributes)
      if attributes['taskid']
        @id = Integer(attributes['taskid']) rescue (raise ArgumentError, 'Task id provided is not an integer')
      else
        raise ArgumentError, 'Task id nont provided'
      end
    end

    def set_priority(attributes)
      if !attributes['priority']
        @priority = nil
      elsif TASK_PRIORITIES.include? attributes['priority']
        @priority = attributes['priority'].downcase.to_sym
      else
        raise ArgumentError, 'Task priority provided is not valid'
      end
    end

    def set_block_status(attributes)
      if attributes['blocked']
        if attributes['blocked'] == '0' || attributes['blocked'] == '1'
          @blocked = attributes['blocked'] == '0' ? false : true
        else
          raise ArgumentError, 'Task block status provided is not 0 or 1'
        end
      else
        @blocked = nil
      end
    end

    def set_deadline(attributes)
      if attributes['deadlineoriginalformat'].nil?
        @deadline = nil
      else
        begin
          @deadline = Date.strptime(attributes['deadlineoriginalformat'], '%Y-%m-%d')
        rescue TypeError, ArgumentError
          raise ArgumentError, 'Task deadline provided is not in %Y-%m-%d format'
        end
      end
    end

    def check_integer(number)
      Integer(number) rescue (raise ArgumentError, 'Not an integer')
    end

    def set_column(attributes)
      if attributes['columnname']
        @column = @board.column(attributes['columnname'])
      else
        raise ArgumentError, 'Task column name not provided'
      end
    end

    def set_lane(attributes)
      if attributes['lanename']
        @lane = @board.lane(attributes['lanename'])
      else
        raise ArgumentError, 'Task lane name not provided'
      end
    end
  end
end
