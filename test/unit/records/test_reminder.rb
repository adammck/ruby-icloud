#!/usr/bin/env ruby
# vim: et ts=2 sw=2

class TestReminder < MiniTest::Unit::TestCase
  def setup
    @cls = ICloud::Records::Reminder
  end

  def test_complete?
    incomplete = @cls.new
    complete = @cls.new.tap { |r| r.completed_date = DateTime.now }
    refute incomplete.complete?
    assert complete.complete?
  end
end
