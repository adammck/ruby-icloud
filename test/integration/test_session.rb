#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "minitest/autorun"
require "icloud"


class TestSession < MiniTest::Unit::TestCase
  def setup
    @session = ICloud::Session.new ENV["APPLE_ID"], ENV["APPLE_PW"], ENV["APPLE_SHARD"], TEST_CLIENT_ID
  end

  def test_reminders
    VCR.use_cassette "session/reminders" do
      arr = @session.reminders
      assert_equal 2, arr.length
    end
  end
end
