#!/usr/bin/env ruby
# vim: et ts=2 sw=2

module ICloud
  module Proxy

    #
    # Public: Returns a URI containing the current proxy server, as set by the
    # environment. If no proxy is set, the URI will be null, e.g. it will return
    # `nil` for every method.
    #
    def proxy
      if proxies.any?
        URI(proxies.first)
      else
        null_proxy
      end
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
    # Internal: Returns a URI which returns `nil` for everything.
    #
    def null_proxy
      URI::Generic.build(Hash.new)
    end

    #
    # Internal: Returns `ENV`. Stub me!
    #
    def env
      ENV
    end
  end
end
