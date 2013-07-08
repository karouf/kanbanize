module Kanbanize
  class Task

    attr_reader :id, :title, :position, :type, :assignee, :description,
                :color, :priority, :size, :deadline, :tags, :lead_time,
                :block_reason, :logged_time

    TASK_PRIORITIES = ['Low', 'Average', 'High']

    def initialize (attributes)
      set_id(attributes)

      @title = attributes['title']
      @type = attributes['type']
      @assignee = attributes['assignee']
      @description = attributes['description']
      @color = attributes['color']
      @size = attributes['size']
      @tags = attributes['tags'].split(' ') if attributes['tags']
      @block_reason = attributes['blockedreason']

      set_priority(attributes)
      set_position(attributes)
      set_block_status(attributes)
      set_lead_time(attributes)
      set_logged_time(attributes)
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

    def set_position(attributes)
      if attributes['position']
        @position = Integer(attributes['position']) rescue (raise ArgumentError, 'Task position provided is not an integer')
      else
        @position = nil
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

    def set_lead_time(attributes)
      if attributes['leadtime']
        @lead_time = Integer(attributes['leadtime']) rescue (raise ArgumentError, 'Task lead time provided is not an integer')
      else
        @lead_time = nil
      end
    end

    def set_logged_time(attributes)
      if attributes['logedtime']
        @logged_time = Integer(attributes['logedtime']) rescue (raise ArgumentError, 'Task logged time provided is not an integer')
      else
        @logged_time = nil
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
  end
end
