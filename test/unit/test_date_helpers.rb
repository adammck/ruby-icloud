#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "date"

class TestDateHelpers < MiniTest::Unit::TestCase
  def setup
    @dt = DateTime.new 1984, 6, 13, 18, 30, 0
    @ic = [19840613, 1984, 6, 13, 18, 30, 1110]
  end

  def test_can_read_icloud_dates
    assert_equal ICloud::date_from_icloud(@ic), @dt
  end

  def test_can_write_icloud_dates
    assert_equal @ic, ICloud::date_to_icloud(@dt)
  end
end
