#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  module Records
    class Collection
      include Record
      has_fields(
        :ctag,
        :title,
        :created_date_extended,
        :completed_count,
        :participants,
        :collection_share_type,
        :created_date,
        :guid,
        :email_notifications,
        :order
      )
    end
  end
end
