#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  module Proxy

    #
    # Public: Returns a URI containing the current proxy server, as set by the
    # environment, or nil if no proxy is set.
    #
    def proxy
      if proxies.any?
        URI(proxies.first)
      else
        nil
      end
    end

    #
    # Public: Returns true if a proxy should be used.
    #
    def use_proxy?
      !! proxy
    end

    #
    # Internal: Returns the list of proxy servers found in the environment.
    # environment. Proxies can be set using the following ENV vars (in order):
    # `HTTPS_PROXY`, `https_proxy`, `HTTP_PROXY`, `http_proxy`.
    #
    def proxies
      %w[HTTPS_PROXY https_proxy HTTP_PROXY http_proxy].map do |key|
        env[key]
      end.compact
    end

    #
    # Internal: Returns `ENV`. Stub me!
    #
    def env
      ENV
    end
  end
end
