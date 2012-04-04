#!/usr/bin/env ruby

require "date"
require "json"
require "logger"
require "mechanize"
require "./secrets"

#Mechanize.log = Logger.new $stderr

module ICloud
  class Session
    def initialize user, pass
      @user = user
      @pass = pass
      @agent = nil
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
      { "origin"=>"https://www.icloud.com" }.update(more)
    end
    
    def params more={}
      { "lang"=>"en-us", "usertz"=>"America/New_York", "dsid"=>dsid }.update(more)
    end
    
    # Extract the current DSID from the cookies.
    def dsid
      @agent.cookie_jar.jar["icloud.com"]["/"]["X-APPLE-WEBAUTH-USER"].value.match(/d=(\d+)/)[1]
    end

    def login_url
      "https://setup.icloud.com/setup/ws/1/login"
    end

    def body
      { :apple_id=>@user, :password=>@pass, :extended_login=>false }
    end
  end

  class Reminders
    def initialize session
      @session = session
      @cache = nil
      update!
    end

    def all
      @cache["Todo"].map do |data|
        Reminder.new self, data
      end
    end

    def alarm guid
      data = @cache["Alarm"].find do |data|
        data["guid"] == guid
      end

      if data
        Alarm.new self, data
      else
        nil
      end
    end

    private

    def update!
      @cache = fetch!
    end

    def fetch!
      JSON.parse @session.get(url).body
    end
    
    def url
      "https://p06-calendarws.icloud.com/ca/todos"
    end
  end


  # {
  # "description"=>"Event reminder",
  # "isLocationBased"=>false,
  # "pGuid"=>"1C779FF9-FBEC-4400-A5C7-5EFF2057680E",
  # "messageType"=>"message",
  # "onDate"=>[20111128, 2011, 11, 28, 9, 0, 540],
  # "guid"=>
  # "1C779FF9-FBEC-4400-A5C7-5EFF2057680E:9CA73BCB-5902-40EC-B6D9-8F0FD8AA1A95"
  # }
  class Alarm
    def initialize set, data
      @set = set
      @data = data
    end

    def date_time
      if @data.has_key? "onDate"
        _, year, month, mday, hour, minute, _ = @data["onDate"]
        DateTime.new year, month, mday, hour, minute
      else
        nil
      end
    end

    def to_s
      if date_time
        date_time.strftime "on %d/%m/%Y at %I:%M%p"

      else
        "(no time)"
      end
    end
  end


  # {
  # "updatedByNameFirst"=>nil,
  # "updatedByName"=>nil,
  # "updatedByDate"=>nil,
  # "hasAttachments"=>false,
  # "lastModifiedDate"=>[20120404, 2012, 4, 4, 12, 3, 723],
  # "pGuid"=>"tasks",
  # "createdByName"=>nil,
  # "extendedDetailsAreIncluded"=>true,
  # "updatedByNameLast"=>nil,
  # "etag"=>"C=135@U=ebe8c12a-8bf9-4a97-8836-9fd8a2eb37c6",
  # "createdByDate"=>nil,
  # "title"=>"Categorize Chocolat on RescueTime",
  # "createdByNameLast"=>nil,
  # "createdDate"=>[20120404, 2012, 4, 4, 12, 3, 723],
  # "alarms"=>["1C779FF9-FBEC-4400-A5C7-5EFF2057680E:9CA73BCB-5902-40EC-B6D9-8F0FD8AA1A95"],
  # "dueDateIsAllDay"=>false,
  # "completedDate"=>[20111128, 2011, 11, 28, 13, 2, 782],
  # "guid"=>"1C779FF9-FBEC-4400-A5C7-5EFF2057680E",
  # "dueDate"=>[20111128, 2011, 11, 28, 9, 0, 540],
  # "createdByNameFirst"=>nil
  # }
  class Reminder
    def initialize set, data
      @set = set
      @data = data
    end

    def title
      @data["title"]
    end
    
    def alarms
      @data["alarms"].map do |guid|
        @set.alarm guid
      end
    end

    def to_s
      title + " -- " + alarms.join(", ")
    end
  end
end

s = ICloud::Session.new($user, $pass)
puts s.reminders.all
