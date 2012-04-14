#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud

  # Public: Convert a snake_cased string to camelCase.
  def self.camel_case str
    str.gsub /_([a-z])/ do
      $1.upcase
    end
  end

  # Convert a camelCased string to snake_case.
  def self.snake_case str
    str.gsub /(.)([A-Z])/ do
      "#{$1}_#{$2.downcase}"
    end.downcase
  end
end
