#!/usr/bin/env ruby
# vim: et ts=2 sw=2

class TestNestedRecord < MiniTest::Unit::TestCase
  def setup
    @pet_cls = Class.new do
      include ICloud::Record
      has_fields :name
    end

    @person_cls = Class.new do
      include ICloud::Record
      has_fields :name, :pets
    end
  end

  def make_pet(name)
    @pet_cls.new.tap do |pet|
      pet.name = name
    end
  end

  def test_serialization
    record = @person_cls.new.tap do |r|
      r.name = "Adam"
      r.pets = [
        make_pet("Mr Jingles"),
        make_pet("Prof Snugglesworth")
      ]
    end

    assert_equal({
      "name" => "Adam",
      "pets" => [
        {"name" => "Mr Jingles"},
        {"name" => "Prof Snugglesworth"},
      ]
    }, record.to_icloud)
  end

  #def test_unserialization
end
