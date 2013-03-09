#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "minitest/mock"

class TestProxy < MiniTest::Unit::TestCase
  def setup
    @cls = Class.new
    @cls.send(:include, ICloud::Proxy)
    @obj = @cls.new
  end

  def test_returns_nil_when_no_proxy_is_configured
    @obj.stub(:env, { }) do
      assert_nil @obj.proxy
    end
  end

  def test_finds_proxy_settings_in_env
    @obj.stub(:env, { "HTTPS_PROXY" => "http://adam:password@example.com:8080" }) do
      @obj.proxy.tap do |uri|
        assert_equal "example.com", uri.host
        assert_equal 8080, uri.port
        assert_equal "adam", uri.user
        assert_equal "password", uri.password
      end
    end
  end
end
