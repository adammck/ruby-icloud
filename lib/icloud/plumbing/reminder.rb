#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
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
  end
end
