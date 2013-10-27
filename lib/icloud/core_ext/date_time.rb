#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require 'date'

class DateTime
  def to_icloud
    ICloud.date_to_icloud(self)
  end
end
