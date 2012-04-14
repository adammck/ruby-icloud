#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Todo
    include Record
    has_fields :description, :etag, :location, :title

    def to_s
      title
    end
  end
end
