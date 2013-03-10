#!/usr/bin/env ruby
# vim: et ts=2 sw=2

# Totally arbitrary GUID for this library
TEST_CLIENT_ID = "61384E90-4A30-4F2A-89C3-E031E77B4B78"

# Consistent for a single test run, otherwise unique.
prefix = "Test #{Time.now.to_i}"
TEST_TITLE_A = "#{prefix}A"
TEST_TITLE_B = "#{prefix}B"

TEST_DATE = DateTime.new(2013, 2, 1, 6, 0)
