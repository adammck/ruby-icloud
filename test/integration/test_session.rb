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
    VCR.use_cassette "session/log_in" do
      assert $session.login!
    end
  end

  def test_01_fetch_collections
    VCR.use_cassette "session/fetch_collections" do
      actual = $session.collections.map(&:title)
      assert_equal_unordered %w[Alpha Beta], actual
    end
  end

  def test_02_fetch_all_reminders
    VCR.use_cassette "session/can_fetch_all_reminders" do
      actual = $session.reminders.map(&:title)
      assert_equal_unordered %w[Foo Bar One Two Three], actual
    end
  end

  def test_03_post_reminders
    VCR.use_cassette "session/post_reminders" do
      $session.post_reminder(ICloud::Records::Reminder.new.tap do |r|
        r.title = TEST_TITLE_A
      end)
    end
  end

  def test_04_new_reminder_is_persisted
    VCR.use_cassette "session/new_reminder_is_persisted" do
      titles = $session.reminders.map(&:title)
      assert_includes titles, TEST_TITLE_A
    end
  end

  def test_05_update_a_reminder
    VCR.use_cassette "session/update_a_reminder" do
      reminder = find(TEST_TITLE_A)
      reminder.title = TEST_TITLE_B
      $session.post_reminder reminder
    end
  end

  def test_06_updated_reminder_is_persisted
    VCR.use_cassette "session/new_reminder_is_persisted" do
      titles = $session.reminders.map(&:title)
      assert_includes titles, TEST_TITLE_B
    end
  end

  def test_07_delete_a_reminder
    VCR.use_cassette "session/delete_a_reminder" do
      reminder = find(TEST_TITLE_B)
      $session.delete_reminder reminder
    end
  end

  def test_08_deleted_reminder_is_persisted
    VCR.use_cassette "session/deleted_reminder_is_persisted" do
      titles = $session.reminders.map(&:title)
      refute_includes titles, TEST_TITLE_B
    end
  end
end
