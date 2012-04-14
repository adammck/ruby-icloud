#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Pool
    def initialize
      @objects = []
    end

    def add obj
      @objects.push obj
    end
    
    def alarms
      find_by_type Alarm
    end
    
    def collections
      find_by_type Collection
    end
    
    def todos
      find_by_type Todo
    end
    
    private
    
    def find_by_type cls
      @objects.select do |obj|
        obj.is_a? cls
      end
    end
  end
end
