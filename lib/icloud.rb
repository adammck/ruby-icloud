#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "json"
require "mechanize"
require "uuidtools"

module ICloud
end

require "icloud/helpers/date_helpers"
require "icloud/record"

require "icloud/plumbing/alarm"
require "icloud/plumbing/todo"

require "icloud/reminders"
require "icloud/session"
require "icloud/version"
