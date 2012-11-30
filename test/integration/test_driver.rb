#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "minitest/autorun"
require "icloud"


class TestDriver < MiniTest::Unit::TestCase
  def setup
    @driver = ICloud::Driver.new ENV["APPLE_ID"], ENV["APPLE_PW"], TEST_CLIENT_ID
  end

  def test_can_log_in
    VCR.use_cassette "driver/login" do
      assert @driver.login!
    end
  end

  def test_can_retrieve_reminders
    VCR.use_cassette "driver/reminders" do
      arr = @driver.reminders
      assert_equal arr.first.title, "Incomplete One"
      assert_equal 1, arr.length
    end
  end

  def test_can_retrieve_completed_reminders
    VCR.use_cassette "driver/completed_reminders" do
      arr = @driver.completed_reminders
      titles = arr.map(&:title)
      assert_includes titles, "Completed One"
      assert_includes titles, "Completed Two"
      assert_equal 2, arr.length
    end
  end
end
