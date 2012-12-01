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
      @pool = Pool.new

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
      @user = Records::DsInfo.from_icloud(body["dsInfo"])
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

    def collections
      update(get_startup)
      @pool.find_by_type(Records::Collection)
    end

    def reminders
      update(get_startup, get_completed)
      @pool.find_by_type(Records::Reminder)
    end

    def update(*args)
      args.each do |hash|
        parse_records(hash).each do |record|
          @pool.add(record)
        end
      end
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

    def get_startup
      ensure_logged_in
      get(service_url(:reminders, "/rd/startup"))
    end

    def get_completed
      ensure_logged_in
      get(service_url(:reminders, "/rd/completed"))
    end

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
    # Internal: Convert a record name (as returned by icloud.com) into a class.
    # Names are downcased and singularized before being resolved.
    #
    def record_class(name, mod=ICloud::Records)
      sym = name.capitalize.sub(/s$/, "").to_sym
      mod.const_get(sym) if mod.const_defined?(sym)
    end

    #
    # Internal: Builds and returns an internal URL.
    #
    def service_url service, path
      @services[service.to_s] + path
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

    #
    # Internal: Parses a nested hash of records (as passed around by icloud.com)
    # into a flat array of record instances, silently ignoring any unrecognized
    # data.
    #
    # Examples
    #
    #   parse_records({
    #     "Collection": [{ "guid": 123 }, { "guid": 456 }],
    #     "Reminder":   [{ "guid": 789 }],
    #     "Whatever":   [{ "junk": 1 }]
    #   })
    #
    #   # => [<Collection:123>, <Collection:456>, <Reminder:789>]
    #
    def parse_records(hash)
      [].tap do |records|
        hash.each do |name, hashes|
          if cls = record_class(name)
            hashes.each do |hsh|
              obj = cls.from_icloud(hsh)
              records.push(obj)
            end
          end
        end
      end
    end
  end
end
