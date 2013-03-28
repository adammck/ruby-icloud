#!/usr/bin/env ruby
# vim: et ts=2 sw=2

class TestNestedRecord < MiniTest::Unit::TestCase
  def setup
    @pet_cls = Class.new do
      include ICloud::Record
      has_fields :name
    end

    # The block passed to Class.new is instance_evalled in the new class (where
    # @pet_cls is nil), so we must alias this to a local so we can access it.
    pc = @pet_cls

    @person_cls = Class.new do
      include ICloud::Record
      has_fields :name
      has_many :pets, pc
    end
  end

  def make_pet(name)
    @pet_cls.new.tap do |pet|
      pet.name = name
    end
  end

  def example_hash
    {
      "name" => "Adam",
      "pets" => [
        {"name" => "Mr Jingles"},
        {"name" => "Prof Snugglesworth"},
      ]
    }
  end

  def example_record
    @person_cls.new.tap do |r|
      r.name = "Adam"
      r.pets = [
        make_pet("Mr Jingles"),
        make_pet("Prof Snugglesworth")
      ]
    end
  end

  def test_serialization
    assert_equal(example_hash, example_record.to_icloud)
  end

  def test_unserialization
    assert_equal(example_record, @person_cls.from_icloud(example_hash))
  end
end
