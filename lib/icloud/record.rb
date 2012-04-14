#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud

  # Public: Mixin to allow a class to be serialized and unserialized into the
  # format spoken by the icloud.com private JSON API.
  module Record
    def self.included base
      base.extend ClassMethods
    end

    # Public: Serialize this record into an iCloud-ish (camelCased) hash.
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
      self.class.to_icloud self
    end

    module ClassMethods

      # Public: Add named fields to this record. This creates the accessors, and
      # keeps track of the field names for [un-]serialization later via the
      # to_icloud and from_icloud methods.
      #
      # Returns nothing.
      def fields *names
        ensure_fields_storage

        names.map(&:to_s).each do |name|
          attr_accessor name
          @fields.push name
        end
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
          @fields.each do |name|
            record.send "#{name}=", hsh[camel_case(name)]
          end
        end
      end

      # Internal: Serialize a record into an iCloud-ish (camelCased) hash. This
      # class method is only public so the same-named instance method can call
      # it. Look there for usage examples.
      #
      # Returns the hash.
      def to_icloud obj
        Hash.new.tap do |hsh|
          @fields.each do |name|
            hsh[camel_case(name)] = obj.send name
          end
        end
      end


      private

      # Convert a camelCased string to snake_case.
      def snake_case str
        str.gsub /(.)([A-Z])/ do
          "#{$1}_#{$2.downcase}"
        end.downcase
      end

      # Convert a snake_cased string to camelCase.
      def camel_case str
        str.gsub /_([a-z])/ do
          $1.upcase
        end
      end

      # Initialize @fields as an empty array, unless it already exists.
      def ensure_fields_storage
        if @fields.nil?
          @fields = []
        end
      end
    end
  end
end
