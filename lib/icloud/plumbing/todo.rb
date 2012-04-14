#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Todo
    include Record
    fields :description, :etag, :location, :title

    def to_s
      title
    end
  end
end
