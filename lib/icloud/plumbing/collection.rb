#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Collection
    include Record
    has_fields(
      :color,
      :created_date,
      :ctag,
      :description,
      :email_notifications,
      :enabled,
      :etag,
      :extended_details_are_included,
      :guid,
      :is_default,
      :last_modified_date,
      :object_type,
      :order,
      :participants,
      :published_url,
      :read_only,
      :share_title,
      :share_type,
      :subscribed_url,
      :supported_type,
      :title
    )
  end
end
