#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Session
    attr_reader :driver, :pool

    def initialize user, pass, shard, client_id=nil
      @driver = Driver.new(user, pass, shard, client_id)
      @pool = Pool.new
    end

    def reminders
      update!

      @pool.todos.map do |todo|
        Reminder.new(self, todo.guid)
      end
    end

    private

    def update!
      @driver.todos_and_alarms.each do |type_name, records|
        records.each do |record|
          @pool.add record
        end
      end
    end

    def record_type name
      ICloud.const_defined?(name) ? ICloud.const_get(name) : nil
    end
  end
end
