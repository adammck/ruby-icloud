#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "date"

module ICloud
  def self.date_from_icloud obj
    _, year, month, mday, hour, minute, _ = obj
    DateTime.new year, month, mday, hour, minute
  end

  def self.date_to_icloud dt
    [
      # The Y/M/D concatenated into an int.
      # I have no idea what this is for.
      dt.strftime("%Y%m%d").to_i,

      # The usual date+time fields. Note that there's no seconds.
      dt.year, dt.month, dt.mday, dt.hour, dt.min,

      # Minutes since midnight.
      (dt.hour * 60) + dt.min
    ]
  end
end
