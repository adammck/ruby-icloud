#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Session
    attr_reader :driver, :pool

    def initialize user, pass
      @driver = Driver.new(user, pass)
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
      @driver.all_todos.each do |type, objects|
        cls = record_type type
      
        objects.each do |hsh|
          record = cls.from_icloud hsh
          @pool.add record
        end
      end
    end

    def record_type name
      ICloud.const_defined?(name) ? ICloud.const_get(name) : nil
    end
  end
end
