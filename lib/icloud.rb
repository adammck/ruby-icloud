#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
end

require "icloud/helpers/date_helpers"
require "icloud/helpers/inflections"

require "icloud/record"
require "icloud/plumbing/alarm"
require "icloud/plumbing/collection"
require "icloud/plumbing/dsinfo"
require "icloud/plumbing/pool"
require "icloud/plumbing/reminder"

# Temporary?
#require "icloud/porcelain/reminder"

require "icloud/errors"
require "icloud/session"
require "icloud/version"
