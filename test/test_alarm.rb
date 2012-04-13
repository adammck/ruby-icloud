#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "minitest/autorun"
require "icloud"


class TestAlarm < MiniTest::Unit::TestCase
  def setup
    @dump = {
      "messageType"     => "message",
      "pGuid"           => "6EBC4134-6567-4D70-8CD6-05F3E8AEC912",
      "guid"            => "6EBC4134-6567-4D70-8CD6-05F3E8AEC912:A57A5E16-D44F-47B0-8BF5-A9E0DA64EB09",
      "description"     => "Event reminder",
      "onDate"          => [20130101, 2013, 1, 1, 9, 0, 540],
      "isLocationBased" => false
    }
  end

  def test_can_unserialize_from_icloud
    alarm = ICloud::Alarm.from_icloud(@dump)

    assert_equal @dump["messageType"],       alarm.message_type
    assert_equal @dump["pGuid"],             alarm.parent_guid
    assert_equal @dump["guid"],              alarm.guid
    assert_equal @dump["description"],       alarm.description
    assert_equal @dump["isLocationBased"],   alarm.is_location_based

    assert_equal "2013-01-01 09:00", alarm.date.strftime("%F %R")
  end

  def test_can_serialize_to_icloud
    alarm = ICloud::Alarm.new.tap do |a|
      a.message_type      = @dump["messageType"]
      a.parent_guid       = @dump["pGuid"]
      a.guid              = @dump["guid"]
      a.description       = @dump["description"]
      a.is_location_based = @dump["isLocationBased"]

      a.date = DateTime.new 2013, 1, 1, 9
    end

    assert_equal @dump, alarm.to_icloud
  end
end
