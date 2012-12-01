#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "minitest/autorun"
require "icloud"


class TestSession < MiniTest::Unit::TestCase
  def setup
    @session = ICloud::Session.new ENV["APPLE_ID"], ENV["APPLE_PW"], TEST_CLIENT_ID
  end

  def test_can_log_in
    VCR.use_cassette "session/login" do
      assert @session.login!
    end
  end

  def test_can_retrieve_reminders
    VCR.use_cassette "session/reminders" do
      arr = @session.reminders
      titles = arr.map(&:title)
      assert_equal 3, arr.length

     %w[One Two Three].each do |title|
        assert_includes titles, "Incomplete #{title}"
      end
    end
  end

  def test_can_retrieve_completed_reminders
    VCR.use_cassette "session/completed_reminders" do
      arr = @session.completed_reminders
      titles = arr.map(&:title)
      assert_equal 2, arr.length

      %w[One Two].each do |title|
        assert_includes titles, "Completed #{title}"
      end
    end
  end
end
