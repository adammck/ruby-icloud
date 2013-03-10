#!/usr/bin/env ruby
# vim: et ts=2 sw=2

class TestSession < MiniTest::Unit::TestCase
  i_suck_and_my_tests_are_order_dependent!

  def assert_equal_unordered(expected, actual)
    assert_equal(expected.sort, actual.sort)
  end

  def find(title)
    $session.reminders.find do |reminder|
      reminder.title == title
    end
  end

  def setup
    $session ||= ICloud::Session.new(ENV["APPLE_ID"], ENV["APPLE_PW"], TEST_CLIENT_ID)
  end

  def test_00_log_in
    assert $session.login!
  end

  def test_01_fetch_collections
    actual = $session.collections.map(&:title)
    assert_equal_unordered %w[Alpha Beta], actual
  end

  def test_02_fetch_all_reminders
    actual = $session.reminders.map(&:title)
    assert_equal_unordered %w[Foo Bar One Two Three], actual
  end

  def test_03_create_reminder
    $session.post_reminder(ICloud::Records::Reminder.new.tap do |r|
      r.title = TEST_TITLE_A
    end)
  end

  def test_04_created_reminder_is_persisted
    titles = $session.reminders.map(&:title)
    assert_includes titles, TEST_TITLE_A
  end

  def test_05_update_reminder
    reminder = find(TEST_TITLE_A)
    reminder.title = TEST_TITLE_B
    $session.put_reminder reminder
  end

  def test_06_updated_reminder_is_persisted
    titles = $session.reminders.map(&:title)
    assert_includes titles, TEST_TITLE_B
  end

  def test_07_add_alarm_to_reminder
    reminder = find(TEST_TITLE_B)
    reminder.alarms = [ICloud::Records::Alarm.new.tap do |a|
      a.on_date = TEST_DATE
    end]
    $session.put_reminder reminder
  end

  def test_08_added_alarm_was_persisted
    reminder = find(TEST_TITLE_B)
    alarms = reminder.alarms.map(&:on_date)
    assert_includes alarms, TEST_DATE
  end

  def test_09_delete_reminder
    reminder = find(TEST_TITLE_B)
    $session.delete_reminder reminder
  end

  def test_10_deleted_reminder_is_persisted
    titles = $session.reminders.map(&:title)
    refute_includes titles, TEST_TITLE_B
  end
end
