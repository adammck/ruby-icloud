#!/usr/bin/env ruby
# vim: et ts=2 sw=2

class Array
  def to_icloud
    map do |item|
      item.to_icloud
    end
  end
end
