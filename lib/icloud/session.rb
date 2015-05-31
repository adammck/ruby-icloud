#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "cgi"
require "uri"
require "net/https"
require "json/pure"

module ICloud
  class Session
    include Proxy

    def initialize apple_id, pass, client_id=nil
      @apple_id = apple_id
      @pass = pass

      @user = nil
      @services = nil

      @http = {}
      @cookies = []

      @request_id = 1
      @client_id = client_id || default_client_id
    end

    def pool
      unless @pool
        @pool = Pool.new
        update(get_startup)
      end
      @pool
    end

    #
    # Public: Logs in to icloud.com or raises some subclass of Net::HTTPError.
    #
    def login!(extended = false)
      uri = URI.parse("https://setup.icloud.com/setup/ws/1/login")
      payload = { "apple_id"=>@apple_id, "password"=>@pass, "extended_login"=>extended }

      response = http(uri.host, uri.port).post(uri.path, payload.to_json, default_headers)
      @cookies = response.get_fields("set-cookie")
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
      ensure_logged_in
      pool.find_by_type(Records::Collection)
    end

    def reminders
      ensure_logged_in
      update(get_completed)
      pool.find_by_type(Records::Reminder)
    end

    def post_reminder(reminder)
      ensure_logged_in

      path = "/rd/reminders/#{reminder.p_guid || 'tasks'}"
      # TODO: Should ClientState always be included in posts?
      post(service_url(:reminders, path), { }, {
        "Reminders" => reminder.to_icloud,
        "ClientState" => client_state
      })
    end

    def put_reminder(reminder)
      ensure_logged_in

      path = "/rd/reminders/#{reminder.p_guid || 'tasks'}"
      # TODO: Should ClientState always be included in posts?
      post(service_url(:reminders, path), { "methodOverride" => "PUT" }, {
        "Reminders" => reminder.to_icloud,
        "ClientState" => client_state
      })
    end

    def put_collection_reminder(reminder)
      ensure_logged_in

      post(service_url(:reminders, "/rd/reminders/#{reminder.p_guid}"), { "methodOverride" => "PUT" }, {
        "Reminders" => reminder.to_icloud,
        "ClientState" => client_state
      })
    end

    def delete_reminder(reminder)
      ensure_logged_in

      path = "/rd/reminders/#{reminder.p_guid || 'tasks'}"
      post(service_url(:reminders, path), { "methodOverride" => "DELETE", "id" => deletion_id }, {
        "Reminders" => [reminder.to_icloud],
        "ClientState" => client_state
      })
    end

    def apply_changeset(cs)
      if cs.include?("updates")
        parse_records(cs["updates"]).each do |record|
          pool.add(record)
        end
      end

      if cs.include?("deletes")
        cs["deletes"].each do |hash|
          pool.delete(hash["guid"])
        end
      end
    end

    def update(*args)
      args.each do |hash|
        parse_records(hash).each do |record|
          pool.add(record)
        end
      end
    end

    # Performs a GET request in this session.
    def get url, params={}, headers={}
      uri = URI.parse(url)
      path = uri.path + "?" + query_string(default_params.merge(params))
      response = http(uri.host, uri.port).get(path, default_headers.merge(headers))
      JSON.parse(response.body)
    end

    # Performs a POST request in this session.
    def post url, params={}, postdata={}, headers={}
      uri = URI.parse(url)
      p = postdata.to_json
      h = default_headers.merge(headers)
      path = uri.path + "?" + query_string(default_params.merge(params))
      response = http(uri.host, uri.port).post(path, p, h)

      if (response.code.to_i) == 200 && (response.content_type == "text/json")
        hash = JSON.parse(response.body)

      else
        raise StandardError.new(
          "Request:\n"                               +
          "path: #{path}\n"                          +
          "headers: #{h}\n"                          +
          "#{p}\n"                                   +
          "Response:\n"                              +
          "--\n"                                     +
          "Response:\n"                              +
          "status: #{response.code}\n"               +
          "content-type: #{response.content_type}\n" +
          response.body)
      end

      # If this response contains a changeset, apply it.
      if hash.include?("ChangeSet")
        apply_changeset(hash["ChangeSet"])
      end

      hash
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

    #
    # Internal: Returns a Net::HTTP object for host:post, which may or may not
    # have already been used. Proxies and SSL are taken care of.
    #
    def http(host, port)
      @http["#{host}:#{port}"] ||= http_class.new(host, port).tap do |http|
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.use_ssl = true
      end
    end

    #
    # Internal: Returns the Net::HTTP class which should be used, which might be
    # a configured Proxy.
    #
    def http_class
      if use_proxy?
        Net::HTTP::Proxy(proxy.host, proxy.port, proxy.user, proxy.password)
      else
        Net::HTTP
      end
    end

    #
    # Internal: Flattens a hash into a query string.
    #
    def query_string(params)
      params.map do |k, v|
        "#{CGI::escape(k)}=#{CGI::escape(v)}"
      end.join("&")
    end

    #
    # Internal: Calls `login!` unless it has already been called.
    #
    def ensure_logged_in
      login! if @user.nil?
    end

    def default_headers
      {
        "origin" => "https://www.icloud.com",
        "cookie" => @cookies.join("; ")
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

    #
    # Returns the current client state, i.e. the `guid` and `ctag` (entity tag)
    # of each collection we know about. The server uses this to decide which
    # records to send back.
    #
    # It looks like multiple record types could be specified here, but haven't
    # seen that.
    #
    def client_state
      {
        "Collections" => collections.map do |c|
          {
            "guid" => c.guid,
            "ctag" => c.ctag,
          }
        end
      }
    end

    #
    # Internal: Returns a random 40 character hex string, which icloud.com needs
    # when deleting a reminder. (I don't know why. It doesn't appear to be used
    # anywhere else.)
    #
    def deletion_id
      SecureRandom.hex(20)
    end

    #
    # Internal: Returns the default client UUID of this library. It's totally
    # arbitrary. Please change if it you substantially fork the library.
    #
    def default_client_id
      "1B47512E-9743-11E2-8092-7F654762BE04"
    end

    def marshal_dump
      [@apple_id, @pass, @client_id, @request_id, @user, @services, @cookies]
    end

    def marshal_load(ary)
      @apple_id, @pass, @client_id, @request_id, @user, @services, @cookies = *ary
      @http = {}
    end

  end
end
