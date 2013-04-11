#!/usr/bin/env ruby
# vim: et ts=2 sw=2

class TestRemindersApp < MiniTest::Unit::TestCase
  def setup
    @mock_session = MiniTest::Mock.new
    @reminders_app = ICloud::Apps::Reminders.new(@mock_session)
  end

  def test_login
    fake_url = "http://example.com/abc"
    fake_startup = { :a => "alpha" }
    @mock_session.expect(:ensure_logged_in, nil)
    @mock_session.expect(:service_url, fake_url, [:reminders, "/rd/startup"])
    @mock_session.expect(:get, fake_startup, [fake_url])
    assert_equal fake_startup, @reminders_app.startup
    assert @mock_session.verify
  end
end
