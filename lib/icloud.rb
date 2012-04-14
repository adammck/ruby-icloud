#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "json"
require "mechanize"
require "uuidtools"

module ICloud
end

require "icloud/helpers/date_helpers"
require "icloud/record"

require "icloud/alarm"
require "icloud/login"
require "icloud/reminders"
require "icloud/session"
require "icloud/todo"
require "icloud/version"
