#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Session
    def initialize user, pass
      @user = user
      @pass = pass
  
      @agent = nil
      @request_id = 1
      @client_id = UUIDTools::UUID.random_create.to_s.upcase
    end
    
    def login!
      if @agent.nil?
        @agent = Mechanize.new
        @agent.post login_url, body.to_json, headers
      end
    end
  
    # Perform a GET request in this session.
    def get(url, p={}, h={})
      login!
      @agent.get url, params(p), nil, headers(h)
    end
    
    def reminders
      Reminders.new self
    end
  
    private
  
    def headers more={}
      {
        # Required:
        "origin"=>"https://www.icloud.com",
        
        # Optional:
        "dnt"=>1
  
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
      @agent.cookie_jar.jar["icloud.com"]["/"]["X-APPLE-WEBAUTH-USER"].value.match(/d=(\d+)/)[1]
    end
  
    def request_id
      @request_id += 1
    end
  
    def login_url
      "https://setup.icloud.com/setup/ws/1/login"
    end
  
    def body
      { :apple_id=>@user, :password=>@pass, :extended_login=>false }
    end
  end
end
