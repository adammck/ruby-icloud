#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Reminders
    def initialize session
      @session = session
      @cache = nil
      update!
    end
  
    def all
      @cache["Todo"].map do |data|
        Todo.from_icloud data
      end
    end
  
    def alarm guid
      data = @cache["Alarm"].find do |data|
        data["guid"] == guid
      end
  
      if data
        Alarm.from_icloud data
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
end
