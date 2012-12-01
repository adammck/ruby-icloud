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

  def test_can_fetch_collections
    VCR.use_cassette "session/collections" do
      actual = @session.collections.map(&:title)
      assert_equal %w[Alpha Beta], actual.sort
    end
  end

  def test_can_fetch_all_reminders
    VCR.use_cassette "session/incomplete_reminders" do
      actual = @session.reminders.map(&:title)
      expected = %w[Foo Bar One Two Three]
      assert_equal expected.sort, actual.sort
    end
  end
end
