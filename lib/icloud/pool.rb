#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Pool
    def initialize
      @objects = {}
    end

    def add obj
      @objects[obj.guid] = obj
    end

    def get guid
      @objects[guid]
    end

    def find hsh
      @objects.values.select do |obj|
        hsh.all? do |k, v|
          obj.send(k) == v
        end
      end
    end

    def changed
      @objects.values.select do |obj|
        obj.changed?
      end
    end

    def delete(guid)
      @objects.delete(guid)
    end




    def alarms
      find_by_type Alarm
    end

    def collections
      find_by_type Collection
    end

    def reminders
      find_by_type Reminder
    end

    def find_by_type cls
      @objects.values.select do |obj|
        obj.is_a? cls
      end
    end
  end
end
