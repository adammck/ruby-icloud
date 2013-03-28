#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud

  # Public: Mixin to allow a class to be serialized and unserialized into the
  # format spoken by the icloud.com private JSON API.
  module Record

    def self.included base
      base.extend ClassMethods
    end

    # Public: Serialize this record's fields into a camelCased-keys hash, ready
    # to be sent to iCloud.
    #
    # Examples
    #
    #   class MyRecord
    #     include ICloud::Record
    #     fields :first_name, :last_name
    #   end
    #
    #   record = MyRecord.new.tap do |r|
    #     r.first_name = "Adam"
    #     r.last_name  = "Mckaig"
    #   end
    #
    #   record.to_icloud
    #   # => { "firstName"=>"Adam", "lastName"=>"Mckaig" }
    #
    # Returns the serialized hash.
    def to_icloud
      Hash.new.tap do |hsh|
        dump.each do |name, val|
          hsh[ICloud.camel_case(name)] = val.to_icloud
        end
      end
    end

    # Internal: Serialize this record.
    # Returns the serialized hash.
    def dump
      Hash.new.tap do |hsh|
        self.class.fields.each do |name, has_many_type|
          hsh[name] = send name
        end
      end
    end

    # Public: Store a copy of this record.
    # Returns nothing.
    def snapshot!
      @snapshot = dump
    end

    # Public: Returns true if this record has changed since `snapshot!` was last
    # called, or if snapshot has never been called.
    def changed?
      @snapshot.nil? or (@snapshot != dump)
    end

    # Public: Returns true if this record is equal-ish to `other`.
    def ==(other)
      other.respond_to?(:to_icloud) && (dump == other.to_icloud)
    end




    module ClassMethods

      # Public: Returns the field names of this record.
      def fields
        @fields or []
      end

      # Public: Add named fields to this record. This creates the accessors, and
      # keeps track of the field names for [un-]serialization later via the
      # to_icloud and from_icloud methods.
      #
      # Returns nothing.
      def has_fields *names
        names.each do |name|
          has_field name
        end
      end

      # TODO: Documentation
      def has_many name, cls
        has_field name, cls
      end

      # TODO: Documentation
      def has_field name, cls=nil
        @fields ||= []
        @fields.push [name.to_s, cls]
        attr_accessor name
      end

      # Public: Create a record from an iCloud-ish (camelCased) hash. To ensure
      # forwards compatibility, any unrecognized keys are silently ignored.
      #
      # hsh - The hash to be unserialized.
      #
      # Examples
      #
      #   class MyRecord
      #     include ICloud::Record
      #     fields :first_name, :last_name
      #   end
      #
      #   hsh = {
      #     "firstName" => "Adam",
      #     "lastName"  => "Mckaig",
      #     "moreStuff" => 123
      #   }
      #
      #   MyRecord.from_icloud(hsh)
      #   # => #<MyRecord:0x123 @first_name="Adam", @last_name="Mckaig">
      #
      # Returns the new record.
      def from_icloud hsh
        self.new.tap do |record|

          fields.each do |name, cls|
            value = hsh[ICloud.camel_case(name)]

            native_value = if cls
              value.map do |v|
                cls.from_icloud(v)
              end
            else
              cast_method = "#{name}_from_icloud"
              respond_to?(cast_method) ? send(cast_method, value) : value
            end

            record.send "#{name}=", native_value
          end

          record.snapshot!
        end
      end
    end
  end
end
