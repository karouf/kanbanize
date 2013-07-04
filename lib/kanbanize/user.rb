module Kanbanize
  class User

    attr_reader :api_key, :username, :realname, :email, :company, :timezone

    def initialize(*args)
      case args.size
      when 1
        @api_key = args[0]
      when 2
        set_attributes(API.new.login(args[0], args[1]))
      else
        raise ArgumentError
      end
      @api = API.new(@api_key)
    end

    def projects
      projects = []
      @api.get_projects_and_boards['projects'].each do |project|
        projects << Project.new(@api, project)
      end
      return projects
    end

    private
    def set_attributes(hash)
      @api_key = hash['apikey']
      @username = hash['username']
      @realname = hash['realname']
      @email = hash['email']
      @company = hash['companyname']
      @timezone = hash['timezone']
    end
  end
end
