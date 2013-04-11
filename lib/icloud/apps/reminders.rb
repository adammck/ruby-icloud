#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  module Apps
    class Reminders

      attr_reader :pool

      #
      # TODO: Maybe move this?
      #
      class Collection
        include Record
        has_fields(
          :ctag,
          :title,
          :created_date_extended,
          :completed_count,
          :participants,
          :collection_share_type,
          :created_date,
          :guid,
          :email_notifications,
          :order
        )
      end

      #
      # Note: Alarms can only be added to existing reminders. Reminders cannot
      # be created with alarms.
      #
      class Alarm
        include Record
        has_fields(
          :description,
          :guid,
          :is_location_based,
          :measurement,
          :message_type,
          :on_date,
          :proximity,
          :structured_location
        )

        #
        # Internal: Cast `value` to a DateTime (for the `on_date` field).
        #
        def self.on_date_from_icloud(value)
          unless value.nil?
            ICloud.date_from_icloud(value)
          end
        end

        # TODO: Move this up to Record?
        def guid
          @guid ||= ICloud.guid
        end

        #
        # Note: Message type MUST be specified, or the service will return a
        # very unhelpful internal server error.
        #
        def message_type
          @message_type ||= "message"
        end

        def inspect
          "#<Alarm %p date=%p>" % [
            description,
            on_date
          ]
        end
      end

      class Reminder
        include Record
        has_fields(
          :completed_date,
          :created_date_extended,
          :created_date,
          :description,
          :due_date,
          :due_date_is_all_day,
          :etag,
          :guid,
          :last_modified_date,
          :order,
          :p_guid,
          :priority,
          :recurrence,
          :start_date,
          :start_date_is_all_day,
          :start_date_tz,
          :title
        )

        has_many(:alarms, Alarm)

        def initialize
          @alarms = []
        end

        #
        # Public: Returns true if this reminder has been marked as complete.
        #
        def complete?
          !! completed_date
        end

        # If this reminder doesn't already have a guid (i.e. it hasn't been
        # persisted) yet, generate one the first time it's read.
        def guid
          @guid ||= ICloud.guid
        end

        # If this reminder doesn't have a parent GUID, assign it to the default
        # list the first time it's read.
        def p_guid
          @p_guid ||= "tasks"
        end
      end

      # ------------------------------------------------------------------------

      #
      # Create a new instance of the Reminders app.
      #
      def initialize(session)
        @session = session
        @pool = Pool.new
      end

      #
      # Public: Creates a reminder.
      #
      def post_reminder(reminder)
        post(url("reminders/tasks"), { }, {
          "Reminders" => reminder.to_icloud,
          "ClientState" => client_state
        })
      end

      #
      # Public: Updates a reminder.
      #
      def put_reminder(reminder)
        post(url("reminders/tasks"), { "methodOverride" => "PUT" }, {
          "Reminders" => reminder.to_icloud,
          "ClientState" => client_state
        })
      end

      #
      # Public: Deletes a reminder.
      #
      def delete_reminder(reminder)
        post(url("reminders/tasks"), { "methodOverride" => "DELETE", "id" => deletion_id }, {
          "Reminders" => [reminder.to_icloud],
          "ClientState" => client_state
        })
      end

      #
      # Public: Fetches and returns **all** reminders.
      #
      def reminders
        update(get_startup)
        update(get_completed)
        @pool.find_by_type(Reminder)
      end

      def get_startup
        @session.ensure_logged_in
        @session.get(url("startup"))
      end

      def get_completed
        @session.ensure_logged_in
        @session.get(url("completed"))
      end

      private

      def url(path)
        @session.service_url(:reminders, "/rd/#{path}")
      end

      def post(url, params={}, postdata={}, headers={})
        @session.ensure_logged_in

        @session.post(url, params, postdata, headers).tap do |hash|
          if hash.include?("ChangeSet")
            apply_changeset(hash["ChangeSet"])
          end
        end
      end

      def update(*args)
        args.each do |hash|
          parse_records(hash).each do |record|
            @pool.add(record)
          end
        end
      end

      #
      # Returns the current client state, i.e. the `guid` and `ctag` (entity
      # tag) of each collection we know about. The server uses this to decide
      # which records to send back.
      #
      # It looks like multiple record types could be specified here, but haven't
      # seen that.
      #
      def client_state
        {
          "Collections" => @pool.find_by_type(Collection).map do |c|
            {
              "guid" => c.guid,
              "ctag" => c.ctag,
            }
          end
        }
      end

      #
      # Internal: Parses a nested hash of records (as returned by icloud.com)
      # into a flat array of record instances, silently ignoring any
      # unrecognized data.
      #
      # Examples
      #
      #   parse_records({
      #     "Collection": [{ "guid": 123 }, { "guid": 456 }],
      #     "Reminder":   [{ "guid": 789 }],
      #     "Whatever":   [{ "junk": 1 }]
      #   })
      #
      #   # => [<Collection:123>, <Collection:456>, <Reminder:789>]
      #
      def parse_records(hash)
        [].tap do |records|
          hash.each do |name, hashes|
            if cls = record_class(name)
              hashes.each do |hsh|
                obj = cls.from_icloud(hsh)
                records.push(obj)
              end
            end
          end
        end
      end

      #
      #
      #
      def apply_changeset(cs)
        if cs.include?("updates")
          parse_records(cs["updates"]).each do |record|
            @pool.add(record)
          end
        end

        if cs.include?("deletes")
          cs["deletes"].each do |hash|
            @pool.delete(hash["guid"])
          end
        end
      end

      #
      # Internal: Constantize a record name (as returned by icloud.com).
      # Names are downcased and singularized before being resolved.
      #
      def record_class(name)
        sym = name.capitalize.sub(/s$/, "").to_sym
        self.class.const_get(sym) if self.class.const_defined?(sym)
      end

      #
      # Internal: Returns a random 40 character hex string, which icloud.com
      # needs when deleting a reminder. (I don't know why. It doesn't appear to
      # be used anywhere else.)
      #
      # TODO: Move this to Session if it's used anywhere other than Reminders.
      #
      def deletion_id
        SecureRandom.hex(20)
      end
    end
  end
end
