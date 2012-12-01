#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  module Records
    class Alarm
      include Record
      has_fields(
        :description,
        :guid,
        :is_location_based,
        :measurement,
        :message_type,
        :on_date,
        :proximity
      )

      def inspect
        "#<Alarm %p date=%p>" % [
          description,
          on_date
        ]
      end
    end
  end
end
