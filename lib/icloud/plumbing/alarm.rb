#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Alarm
    include Record
    has_fields :description, :guid, :is_location_based, :message_type, :on_date, :p_guid

    def inspect
      "#<Alarm %p date=%p>" % [
        description,
        on_date
      ]
    end
  end
end
