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
      assert @driver.login
    end
  end

  def test_list_todos
    VCR.use_cassette "driver/list_todos" do
      hsh = @driver.todos_and_alarms
      assert_includes hsh, "Todo"
      assert_equal 2, hsh["Todo"].length
    end
  end
end
