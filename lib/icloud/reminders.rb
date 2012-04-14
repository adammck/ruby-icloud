#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Reminders
    def initialize session
      @session = session
      @pool = Pool.new
      update!
    end

    def all
      @pool.todos
    end

    private

    def update!
      data = fetch!

      data["Alarm"].each do |data|
        @pool.add Alarm.from_icloud data
      end

      data["Todo"].each do |data|
        @pool.add Todo.from_icloud data
      end
    end

    def fetch!
      JSON.parse @session.get(url).body
    end

    def url
      "https://p06-calendarws.icloud.com/ca/todos"
    end
  end
end
