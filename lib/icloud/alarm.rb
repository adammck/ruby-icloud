#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Alarm
    attr_accessor :message_type, :parent_guid, :guid, :description, :date, :is_location_based

    def self.from_icloud h
      Alarm.new.tap do |a|
        a.message_type      = h["messageType"]
        a.parent_guid       = h["pGuid"]
        a.guid              = h["guid"]
        a.description       = h["description"]
        a.date              = h["onDate"] ? ICloud::date_from_icloud(h["onDate"]) : nil
        a.is_location_based = h["isLocationBased"]
      end
    end

    def to_icloud
      {
        "messageType"     => message_type,
        "pGuid"           => parent_guid,
        "guid"            => guid,
        "description"     => description,
        "onDate"          => ICloud::date_to_icloud(date),
        "isLocationBased" => is_location_based
      }
    end

    def to_s
      if date
        date.strftime "on %d/%m/%Y at %I:%M%p"

      else
        "(no time)"
      end
    end
  end
end
