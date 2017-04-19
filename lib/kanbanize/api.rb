require 'httparty'
require 'uri'

module Kanbanize

  # Low level API calls
  #
  class API
    include HTTParty

    format :json

    # @return [String] the API key used for API calls
    attr_reader :apikey, :base_uri

    # @param apikey [String] the API key to use to connect to the Kanbanize API
    def initialize(subdomain, apikey)
      @apikey = apikey
      @subdomain = subdomain
      @base_uri = "https://#{subdomain}.kanbanize.com/index.php/api/kanbanize"
      set_proxy
    end

    # Log in to the API with the credentials provided
    #
    # @see http://kanbanize.com/ctrl_integration#login
    #
    # @param email [String] the email of the user to login as
    # @param password [String] the password of the user
    #
    # @return [Hash] User infos
    #
    def login(email, pass)
      self.class.post(base_uri + "/login/email/#{uri_encode(email)}/pass/#{uri_encode(pass)}/format/json")
    end

    # Get projects and corresponding boards
    #
    #
    # Format of the returned hash:
    #
    #   { 'projects' => [
    #                     { 'name'    => 'Kanban project',
    #                       'id'      => '1',
    #                       'boards'  =>  [
    #                                       {
    #                                         'name'  => 'Kanban board',
    #                                         'id'    => '2'
    #                                       }
    #                                     ]
    #                     }
    #                   ]
    #   }
    #
    # @see http://kanbanize.com/ctrl_integration#get_projects_and_boards
    #
    # @return [Hash]
    #
    def get_projects_and_boards
      post('/get_projects_and_boards')
    end

    # Get the structure of a board
    #
    #
    # Format of the returned hash:
    #
    #   { 'columns' => [{
    #                     'position'    => '0',
    #                     'lcname'      => 'Column name',
    #                     'description' => 'A nice vertical column',
    #                     'tasksperrow' => '3'
    #                   }],
    #     'lanes'   => [{
    #                     'lcname' => 'Urgent',
    #                     'color' => '#d99f9f',
    #                     'description' => 'Do now!'
    #                   }]
    #   }
    #
    #
    # @see http://kanbanize.com/ctrl_integration#get_board_structure
    #
    # @param board_id [Integer] the id of the board
    #
    # @return [Hash] the columns and lanes of the board
    #
    def get_board_structure(board_id)
      post("/get_board_structure/boardid/#{board_id}")
    end

    # Get the settings for a board
    #
    #
    # Format of the returned hash:
    #
    #   {  'usernames' => ['owner'],
    #      'templates' => ['Bug','Feature','Support'],
    #      'types'     => ['Bug','Feature request','Support request']
    #   }
    #
    #
    # @see http://kanbanize.com/ctrl_integration#get_board_settings
    #
    # @param board_id [Integer] the id of the board
    #
    # @return [Hash] the settings of the board
    #
    def get_board_settings(board_id)
      post("/get_board_settings/boardid/#{board_id}")
    end

    # Get events for a board
    #
    #
    # Format of the returned hash:
    #
    #   { 'allactivities' => 105,
    #     'page'          => 1,
    #     'activities'    => [
    #                           { 'author'  => 'owner',
    #                             'event'   => 'Task moved',
    #                             'text'    => 'From <em>'Backlog'<\/em> to <em>'Next'<\/em>',
    #                             'date'    => '2013-07-09 16:30:13',
    #                             'taskid'  => '12'
    #                           }
    #                         ]
    #   }
    #
    #
    # @see http://kanbanize.com/ctrl_integration#get_board_activities
    #
    # @param  board_id  [Integer]  the id of the board
    # @param  from      [Date]     the date after which you want to get the events
    # @param  to        [Date]     the date before which you want to get the events
    # @param  options   [Hash]     options to paginate and filter events
    # @option options   [Integer]  :page (1) the page number
    # @option options   [Integer]  :results (30) the number of results per page
    # @option options   [String]   :author User the events are related to
    # @option options   [String]   :events the type of events
    #
    # @return [Hash] the selected events
    #
    def get_board_activities(board_id, from, to, options = {})
      uri = "/get_board_activities/boardid/#{board_id}/fromdate/#{from}/todate/#{to}"
      uri += "/page/#{options[:page]}" if options[:page]
      uri += "/resultsperpage/#{options[:results]}" if options[:results]
      uri += "/author/#{options[:author]}" if options[:author]
      uri += "/eventtype/#{options[:events]}" if options[:events]

      post(uri)
    end

    # Get tasks from a board
    #
    # Format of the returned array:
    #
    #   [
    #     {
    #       'taskid' => '1',
    #       'position' => '0',
    #       'type' => 'Feature request',
    #       'assignee' => 'karouf',
    #       'title' => 'Write Api specs',
    #       'description' => '',
    #       'subtasks' => '1',
    #       'subtaskscomplete' => '0',
    #       'color' => '#b3b340',
    #       'priority' => 'Average',
    #       'size' => null,
    #       'deadline' => null,
    #       'deadlineoriginalformat' => null,
    #       'extlink' => null,
    #       'tags' => null,
    #       'columnid' => 'progress_2',
    #       'laneid' => '7',
    #       'leadtime' => 42,
    #       'blocked' => '0',
    #       'blockedreason' => null,
    #       'subtaskdetails' => [],
    #       'columnname' => 'In progress',
    #       'lanename' => 'Standard',
    #       'columnpath' => 'In progress',
    #       'logedtime' => 0
    #     },
    #     .
    #     .
    #     .
    #   ]
    #
    # @see http://kanbanize.com/ctrl_integration#get_all_tasks
    #
    # @param board_id [Integer] the id of the board
    # @param options [Hash] options to filter and paginate the tasks to get
    # @option options [Integer] :page (1) the page number
    # @option options [Boolean] :archive (false) archived tasks or not
    # @option options [Boolean] :subtasks (false) get subtasks or not
    # @option options [Date] :from the date after which you want to get the tasks
    # @option options [Date] :to the date before which you want to get the tasks
    # @option options [String] :version name of the version
    #
    # @raise [ArgumentError] if page number is not an integer
    # @raise [ArgumentError] if page number is not > 0
    #
    # @return [Array<Hash>] the tasks selected
    #
    def get_all_tasks(board_id, options = {})
      raise ArgumentError if options[:page] && !options[:page].kind_of?(Integer)
      raise ArgumentError if options[:page] && (options[:page] < 1)

      if options.delete(:archive)
        return get_archived_tasks(board_id, options)
      else
        return get_board_tasks(board_id, options)
      end
    end

    # Get detailed infos on a task
    #
    # Format of the returned hash:
    #
    #   { 'taskid' => '7',
    #     'title' => 'Write Api specs',
    #     'description' => '',
    #     'type' => 'Feature request',
    #     'assignee' => 'karouf',
    #     'subtasks' => '1',
    #     'subtaskscomplete' => '0',
    #     'color' => '#b3b340',
    #     'priority' => 'Average',
    #     'size' => null,
    #     'deadline' => null,
    #     'deadlineoriginalformat' => null,
    #     'extlink' => null,
    #     'tags' => null,
    #     'leadtime' => 42,
    #     'blocked' => '0',
    #     'blockedreason' => null,
    #     'columnname' => 'En cours',
    #     'lanename' => 'Standard',
    #     'subtaskdetails' => [{  'taskid' => '42',
    #                             'assignee' => 'None',
    #                             'title' => 'Some stuff to do',
    #                             'completiondate' => null
    #                         }],
    #     'columnid' => 'progress_2',
    #     'laneid' => '7',
    #     'columnpath' => 'En cours',
    #     'loggedtime' => 0,
    #     'historydetails' => [
    #                           {  'eventtype' => 'Unarchive',
    #                              'historyevent' => 'Task unarchived',
    #                              'details' => 'Task: Test',
    #                              'author' => 'karouf',
    #                              'entrydate' => '27 Jun 13, 10:02',
    #                              'historyid' => '88'
    #                           }, ...
    #                         ]
    #   }
    #
    #
    # @see http://kanbanize.com/ctrl_integration#get_task_details
    #
    # @param board_id [Integer] the id of the board
    # @param task_id [Integer] the id of the task
    # @param options [Hash] options for the history of the task
    # @option [Boolean] :history (false) get the history or not
    # @option [String] :event the type of events
    #
    # return [Hash] details of the task
    #
    def get_task_details(board_id, task_id, options = {})
      uri = "/get_task_details/boardid/#{board_id}/taskid/#{task_id}"
      uri += '/history/yes' if options[:history]
      uri += "/event/#{options[:event]}" if options[:event]

      post(uri)
    end

    private
    def post(uri)
      self.class.post(base_uri + uri + '/format/json', :headers => {'apikey' => @apikey}).parsed_response
    end

    def set_proxy
      if ENV['http_proxy'].nil?
        self.class.http_proxy
      else
        proxy = ENV['http_proxy'].match(/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?/)[4]

        host, port = proxy.split(':')
        self.class.http_proxy host, port.to_i
      end
    end

    def uri_encode(string)
      URI.escape(string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end

    def get_archived_tasks(board_id, options = {})
      uri = "/get_all_tasks/boardid/#{board_id}/container/archive"
      uri += '/subtasks/yes' if options[:subtasks]
      uri += "/fromdate/#{options[:from]}" if options[:from]
      uri += "/todate/#{options[:to]}" if options[:to]
      uri += "/version/#{options[:version]}" if options[:version]
      uri += "/page/#{options[:page]}" if options[:page]
      post(uri)
    end

    def get_board_tasks(board_id, options = {})
      uri = "/get_all_tasks/boardid/#{board_id}"
      uri += '/subtasks/yes' if options[:subtasks]
      uri += "/page/#{options[:page]}" if options[:page]
      post(uri)
    end
  end
end
