#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Reminder
    def initialize session, guid
      @session = session
      @guid = guid
    end

    def session
      @session or ICloud.session
    end

    def title
      todo.title
    end
    
    def title= val
      todo.title = val
    end

    def save!
      session.driver.commit_todo todo
    end

    def remind_at
      if not alarms.empty? and alarms.first.on_date
        ICloud.date_from_icloud(alarms.first.on_date)
      end
    end

    def to_s
      if remind_at
        "%s (remind at %s on %s)" % [title, time(remind_at), date(remind_at)]
      else
        title
      end
    end

    private

    def pool
      @session.pool
    end

    def todo
      pool.get @guid
    end
    
    def alarms
      pool.find :p_guid=>todo.guid
    end
    
    def date dt
      dt.strftime("%d/%m/%Y")
    end
    
    def time dt
      dt.strftime("%I:%M %p")
    end
  end
end
