#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  module Records
    class Reminder
      include Record
      has_fields(
        :alarms,
        :completed_date,
        :created_date_extended,
        :created_date,
        :description,
        :due_date,
        :due_date_is_all_day,
        :etag,
        :guid,
        :last_modified_date,
        :order,
        :p_guid,
        :priority,
        :recurrence,
        :start_date,
        :start_date_is_all_day,
        :start_date_tz,
        :title
      )

      def initialize
        @alarms = []
      end

      #
      # Public: Returns true if this reminder has been marked as complete.
      #
      def complete?
        !! completed_date
      end

      # When alarms are added to this reminder, wrap them in Alarm objects.
      # TODO: Replace this with a cast method.
      def alarms=(alarms)
        @alarms = alarms.map do |alarm|
          if alarm.is_a?(Hash)
            Alarm.from_icloud(alarm)
          else
            alarm
          end
        end
      end

      # If this reminder doesn't already have a guid (i.e. it hasn't been
      # persisted) yet, generate one the first time it's read.
      def guid
        @guid ||= ICloud.guid
      end

      # If this reminder doesn't have a parent GUID, assign it to the default
      # list the first time it's read.
      def p_guid
        @p_guid ||= "tasks"
      end
    end
  end
end
