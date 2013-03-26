#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  module Records
    #
    # Note: Alarms can only be added to existing reminders. Reminders cannot be
    # created with alarms.
    #
    class Alarm
      include Record
      has_fields(
        :description,
        :guid,
        :is_location_based,
        :measurement,
        :message_type,
        :on_date,
        :proximity,
        :structured_location
      )

      #
      # Internal: Cast `value` to a DateTime (for the `on_date` field).
      #
      def self.on_date_from_icloud(value)
        unless value.nil?
          ICloud.date_from_icloud(value)
        end
      end

      # TODO: Move this up to Record?
      def guid
        @guid ||= ICloud.guid
      end

      #
      # Note: Message type MUST be specified, or the service will return a very
      # unhelpful internal server error.
      #
      def message_type
        @message_type ||= "message"
      end

      def inspect
        "#<Alarm %p date=%p>" % [
          description,
          on_date
        ]
      end
    end
  end
end
