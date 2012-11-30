#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Session
    attr_reader :driver, :pool

    def initialize user, pass, client_id=nil
      @driver = Driver.new(user, pass, client_id)
      @pool = Pool.new
    end

    def all_reminders
      update!
      @pool.reminders
    end

    def user
      @driver.user
    end

    private

    def update!
      (@driver.reminders + @driver.completed_reminders).each do |record|
        @pool.add(record)
      end
    end

    def record_type name
      ICloud.const_defined?(name) ? ICloud.const_get(name) : nil
    end
  end
end
