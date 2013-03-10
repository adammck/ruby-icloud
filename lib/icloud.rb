#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
end

require "icloud/core_ext/array"
require "icloud/core_ext/date_time"
require "icloud/core_ext/object"

require "icloud/helpers/date_helpers"
require "icloud/helpers/guid"
require "icloud/helpers/inflections"
require "icloud/helpers/proxy"

require "icloud/record"
require "icloud/records/alarm"
require "icloud/records/collection"
require "icloud/records/dsinfo"
require "icloud/records/reminder"

require "icloud/porcelain/reminder"

require "icloud/errors"
require "icloud/pool"
require "icloud/session"
require "icloud/version"
