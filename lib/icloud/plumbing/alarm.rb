#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Alarm
    include Record
    has_fields :description, :guid, :is_location_based, :message_type, :on_date, :p_guid

    def to_s
      if date
        date.strftime "on %d/%m/%Y at %I:%M%p"

      else
        "(no time)"
      end
    end
  end
end
