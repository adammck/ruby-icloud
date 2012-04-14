#!/usr/bin/env ruby
# vim: et ts=2 sw=2

require "minitest/autorun"
require "icloud"


class TestRecord < MiniTest::Unit::TestCase
  def setup
    @cls = Class.new do
      include ICloud::Record
      fields :first_name, :last_name
    end
  end

  def test_serialization
    record = @cls.new.tap do |r|
      r.first_name = "Adam"
      r.last_name  = "Mckaig"
    end

    assert_equal({
      "firstName" => "Adam",
      "lastName"  => "Mckaig"
    }, record.to_icloud)
  end

  def test_unserialization
    record = @cls.from_icloud({
      "firstName" => "Adam",
      "lastName"  => "Mckaig",
      "junk"      => 123
    })

    assert_equal "Adam", record.first_name
    assert_equal "Mckaig", record.last_name
    refute_respond_to record, :junk
  end
end
