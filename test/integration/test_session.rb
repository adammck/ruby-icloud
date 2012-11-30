#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "minitest/autorun"
require "icloud"


class TestSession < MiniTest::Unit::TestCase
  def setup
    @session = ICloud::Session.new ENV["APPLE_ID"], ENV["APPLE_PW"], TEST_CLIENT_ID
  end

  def test_all_reminders
    VCR.use_cassette "session/all_reminders" do
      arr = @session.all_reminders
      assert_equal 3, arr.length
    end
  end
end
