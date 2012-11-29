#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "vcr"

# Totally arbitrary GUID for this library
TEST_CLIENT_ID = "61384E90-4A30-4F2A-89C3-E031E77B4B78"

VCR.configure do |c|
  here = File.dirname(__FILE__)
  c.allow_http_connections_when_no_cassette = false
  c.default_cassette_options = { :re_record_interval => (7 * 86400) }
  c.cassette_library_dir = "#{here}/fixtures/cassettes"
  c.hook_into :webmock
end
