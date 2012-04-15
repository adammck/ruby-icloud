#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Todo
    include Record
    has_fields :alarms, :created_by_date, :created_by_name, :created_by_name_first,
               :created_by_name_last, :created_date, :due_date, :due_date_is_all_day,
               :etag, :extended_details_are_included, :guid, :has_attachments,
               :last_modified_date, :p_guid, :title, :updated_by_date, :updated_by_name,
               :updated_by_name_first, :updated_by_name_last
  end
end
