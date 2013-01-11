#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "uuidtools"


module ICloud

  # Public: Returns a random GUID.
  def self.guid
    UUIDTools::UUID.random_create.to_s.upcase
  end
end
