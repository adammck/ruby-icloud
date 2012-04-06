#!/usr/bin/env rake
# vim: et ts=2 sw=2

# Commented out 
#require "bundler/gem_tasks"

$LOAD_PATH << File.expand_path("./lib", File.dirname(__FILE__))
require "icloud"
require "./secrets"

task :reminders do
  session = ICloud::Session.new($APPLE_ID, $PASSWORD)
  puts session.reminders.all
end
