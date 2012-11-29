#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "uuidtools"
require "mechanize"
require "json"

module ICloud
  class Driver
    def initialize apple_id, pass, shard, client_id=nil
      @apple_id = apple_id
      @pass = pass
      @shard = shard

      @user = nil
      @services = nil

      @agent = nil
      @request_id = 1
      @client_id = client_id || UUIDTools::UUID.random_create.to_s.upcase
    end

    def user
      ensure_logged_in
      @user
    end

    def services
      ensure_logged_in
      @services
    end

    def todos_and_alarms
      ensure_logged_in
      records get "https://p#{shard}-calendarws.icloud.com/ca/todos"
    end

    def reminders
      url = @services["reminders"] + "/rd/startup"
      records(get(url))["Reminder"]
    end

    def commit_todo todo
      # params? startDate, endDate

      begin
      post\
        "https://p#{shard}-calendarws.icloud.com/ca/todos/%s/%s" % [todo.p_guid, todo.guid],
        { "ifMatch"=>todo.etag, "methodOverride"=>"PUT" },
        { "Todo"=>todo.to_icloud, "fullState"=>false }
      rescue StandardError => err
        require "debugger"; debugger
        puts nil
      end
    end




    # Public: Log in to icloud.com.
    # Returns true if the login was successful.
    def login
      response = agent.post\
        "https://setup.icloud.com/setup/ws/1/login",
        { "apple_id"=>@apple_id, "password"=>@pass, "extended_login"=>false }.to_json,
        headers

      body = JSON.parse(response.body)
      @user = DsInfo.from_icloud(body["dsInfo"])
      @services = parse_services(body["webservices"])

      true
    end

    def login!
      login or raise ICloud::LoginFailed
    end

    # Perform a GET request in this session.
    def get url, p={}, h={}
      response = agent.get url, params(p), nil, headers(h)
      JSON.parse response.body
    end

    # Perform a POST request in this session.
    def post url, p={}, query={}, h={}
      full_url = "%s?%s" % [url, Mechanize::Util.build_query_string(params(p))]
      response = agent.post full_url, query.to_json, headers(h)
      JSON.parse response.body
    end

    private

    def agent
      @agent ||= Mechanize.new
    end

    def shard
      "%02d" % [@shard]
    end

    def ensure_logged_in
      login! if @user.nil?
    end

    def headers more={}
      {
        # Required:
        "origin" => "https://www.icloud.com",

        # Optional:
        "dnt" => 1

      }.update(more)
    end

    def params more={}
      {
        # Required:
        "lang" => "en-us",
        "usertz" => "America/New_York",
        "dsid" => dsid,

        # Optional:
        "requestID" => request_id,
        "clientID" => @client_id,
        "clientVersion"=>  "3.1"

      }.update(more)
    end

    # Extract the current DSID from the cookies.
    def dsid
      agent.cookie_jar.jar["icloud.com"]["/"]["X-APPLE-WEBAUTH-USER"].value.match(/d=(\d+)/)[1]
    end

    def request_id
      @request_id += 1
    end

    # Internal: Replace the serialized records in an iCloud-ish with instances.
    #
    #   data - the data structure to be mangled.
    #
    # Examples
    #
    #   records { "Alarm": [], "Todo": [{"guid": 123}]
    #   # => { "Alarm": [], "Todo": [<Todo:0x123 @guid=123>]
    #
    # Returns the hash of arrays of new objects.
    def records data
      Hash.new.tap do |hsh|
        data.each do |name, records|
          name = name.gsub(/s$/, "")
          cls = record_class(name)

          hsh[name] = records.map do |hsh|
            cls.from_icloud hsh
          end
        end
      end
    end

    def record_class name
      ICloud.const_defined?(name) ? ICloud.const_get(name) : nil
    end

    # Internal: Parse the "webservices" value returned during login into a hash
    # of name=>url.
    def parse_services(json)
      Hash.new.tap do |hsh|
        json.map do |name, params|
          if params["status"] == "active"
            hsh[name] = params["url"]
          end
        end
      end
    end
  end
end
