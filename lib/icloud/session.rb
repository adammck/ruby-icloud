#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "uuidtools"
require "mechanize"
require "json"

module ICloud
  class Session
    def initialize apple_id, pass, client_id=nil
      @apple_id = apple_id
      @pass = pass

      @user = nil
      @services = nil

      @agent = nil
      @request_id = 1
      @client_id = client_id || UUIDTools::UUID.random_create.to_s.upcase
    end

    #
    # Public: Logs in to icloud.com or raises some subclass of Net::HTTPError.
    #
    def login!
      response = agent.post(
        "https://setup.icloud.com/setup/ws/1/login",
        { "apple_id"=>@apple_id, "password"=>@pass, "extended_login"=>false }.to_json,
        default_headers)

      body = JSON.parse(response.body)
      @user = DsInfo.from_icloud(body["dsInfo"])
      @services = parse_services(body["webservices"])

      true
    end

    def user
      ensure_logged_in
      @user
    end

    def services
      ensure_logged_in
      @services
    end

    def reminders
      ensure_logged_in
      response = get(service_url(:reminders, "/rd/startup"))
      records(response)["Reminders"]
    end

    def completed_reminders
      ensure_logged_in
      response = get(service_url(:reminders, "/rd/completed"))
      records(response)["Reminders"]
    end

    # Performs a GET request in this session.
    def get url, params={}, headers={}
      response = agent.get(url, default_params.merge(params), nil, default_headers.merge(headers))
      JSON.parse(response.body)
    end

    # Performs a POST request in this session.
    def post url, params={}, postdata={}, headers={}
      full_url = "%s?%s" % [url, Mechanize::Util.build_query_string(default_params.merge(params))]
      response = agent.post(full_url, postdata.to_json, default_headers.merge(headers))
      JSON.parse(response.body)
    end

    private

    def agent
      @agent ||= Mechanize.new
    end

    #
    # Internal: Calls `login!` unless it has already been called.
    #
    def ensure_logged_in
      login! if @user.nil?
    end

    def default_headers
      {
        "origin" => "https://www.icloud.com"
      }
    end

    def default_params
      {
        "lang" => "en-us",
        "usertz" => "America/New_York",
        "dsid" => @user.dsid
      }
    end

    #
    # Internal: Builds and returns an internal URL.
    #
    def service_url service, path
      @services[service.to_s] + path
    end

    #
    # Internal: Replace the serialized records in an iCloud-ish with instances.
    # unknown record types are ignored.
    #
    #   data - the data structure to be mangled.
    #
    # Examples
    #
    #   records { "Alarm": [], "Todo": [{"guid": 123}] }
    #   # => { "Alarm": [], "Todo": [<Todo:0x123 @guid=123>]
    #
    #   records { "Unknown": [{"guid": 123}] }
    #   # => { }
    #
    # Returns the hash of arrays of new objects.
    #
    def records data
      Hash.new.tap do |hsh|
        data.each do |name, records|

          cls = record_class(name)
          unless cls.nil?

            hsh[name] = records.map do |hsh|
              cls.from_icloud(hsh)
            end
          end
        end
      end
    end

    def record_class name
      singular = name.gsub(/s$/, "")
      ICloud.const_defined?(singular) ? ICloud.const_get(singular) : nil
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
