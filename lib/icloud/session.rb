#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "cgi"
require "uri"
require "digest/sha1"
require "net/https"
require "json/pure"

module ICloud
  class Session
    include Proxy

    def initialize apple_id, pass, client_id=nil
      @apple_id = apple_id
      @pass = pass
      @client_id = client_id || default_client_id

      @http = {}
      @cookies = []

      @user = nil
      @services = nil

      # This appears to be a magic token which is given at login, which must be
      # passed back (as a sha1 hash along with the apple_id) with some requests.
      # The reminders app doesn't seem to care, but (at least) contacts does.
      @instance = nil
    end

    #
    # Public: Logs in to icloud.com or raises some subclass of Net::HTTPError.
    #
    def login!
      uri = URI.parse("https://setup.icloud.com/setup/ws/1/login")
      payload = { "apple_id"=>@apple_id, "password"=>@pass, "extended_login"=>false }

      response = http(uri.host, uri.port).post(uri.path, payload.to_json, default_headers)
      @cookies = response.get_fields("set-cookie")
      body = JSON.parse(response.body)

      @user = Records::DsInfo.from_icloud(body["dsInfo"])
      @services = parse_services(body["webservices"])
      @instance = body["instance"]

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

    # Performs a GET request in this session.
    def get url, params={}, headers={}
      uri = URI.parse(url)
      path = uri.path + "?" + query_string(default_params.merge(params))

      # puts
      # puts "GET"
      # puts path
      # puts default_headers.merge(headers)
      # puts

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

      hash
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
        "locale" => "en_US",
        "usertz" => "America/New_York",
        "dsid" => @user.dsid,
        "id" => token
      }
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
    # Internal: Returns the default client UUID of this library. It's totally
    # arbitrary. Please change if it you substantially fork the library.
    #
    def default_client_id
      "1B47512E-9743-11E2-8092-7F654762BE04"
    end

    #
    # Internal: Returns a magic hash derived from the current `@instance` and
    # `@apple_id`. I'm not sure exactly what this is for, right now. Some app
    # requests won't work without it.
    #
    def token
      Digest::SHA1.hexdigest(@apple_id + @instance).upcase
    end
  end
end
