module Kanbanize
  class Task

    attr_reader :id, :title, :position, :type, :assignee, :description,
                :color, :priority, :size, :deadline, :tags, :lead_time,
                :block_reason, :logged_time

    TASK_SIZES      = [nil, 'S', 'M', 'L', 'XL', 'XXL', 'XXXL']
    TASK_PRIORITIES = ['Low', 'Average', 'High']

    def initialize (attributes)
      @id = Integer(attributes['taskid']) rescue (raise ArgumentError, 'Task id provided is not an integer')

      @title = attributes['title']
      @block_reason = attributes['blockedreason']
      @type = attributes['type']
      @assignee = attributes['assignee']
      @color = attributes['color']
      @description = attributes['description']
      @tags = attributes['tags'].split(' ') if attributes['tags']

      if TASK_PRIORITIES.include? attributes['priority']
        @priority = attributes['priority'].downcase.to_sym
      else
        raise ArgumentError, 'Task size provided is not valid'
      end

      @position = Integer(attributes['position']) rescue (raise ArgumentError, 'Task position provided is not an integer')

      if attributes['blocked'] == '0' || attributes['blocked'] == '1'
        @blocked = attributes['blocked'] == '0' ? false : true
      else
        raise ArgumentError, 'Task block status provided is not 0 or 1'
      end

      @lead_time = Integer(attributes['leadtime']) rescue (raise ArgumentError, 'Task lead time provided is not an integer')

      @logged_time = Integer(attributes['logedtime']) rescue (raise ArgumentError, 'Task logged time provided is not an integer')

      if attributes['deadlineoriginalformat'].nil?
        @deadline = nil
      else
        begin
          @deadline = Date.strptime(attributes['deadlineoriginalformat'], '%Y-%m-%d')
        rescue TypeError, ArgumentError
          raise ArgumentError, 'Task deadline provided is not in %Y-%m-%d format'
        end
      end

      if TASK_SIZES.include? attributes['size']
        attributes['size'].nil? ? @size = nil : @size = attributes['size'].to_sym
      else
        raise ArgumentError, 'Task size provided is not valid'
      end
    end

    def blocked?
      @blocked
    end
  end
end
