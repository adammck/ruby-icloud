#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  class Error < StandardError; end
  class LoginFailed < Error; end

  #
  # This error should be raised when a request to icloud.com fails. The server
  # usually responds with something helpful.
  #
  class RequestError < Error
    def initialize(status, message)
      @status = status
      @message = message
    end

    def to_s
      "%s (%s)" % [@message, @status]
    end
  end
end
