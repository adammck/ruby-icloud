#!/usr/bin/env ruby
# vim: et ts=2 sw=2

class TestAlarm < MiniTest::Unit::TestCase
  def setup
    @cls = ICloud::Records::Alarm
  end

  def test_on_date_from_icloud
    assert_equal DateTime.new(2013, 6, 13, 7, 45), @cls.on_date_from_icloud([20130613, 2013, 6, 13, 7, 45, 465])
    assert_nil @cls.on_date_from_icloud(nil)
  end
end
