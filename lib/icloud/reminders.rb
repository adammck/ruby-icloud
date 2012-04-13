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
        Reminder.new self, data
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
      title + " -- " + alarms.map(&:to_s).join(", ")
    end
  end
end
