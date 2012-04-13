#!/usr/bin/env rake
# vim: et ts=2 sw=2

require "rake/testtask"

$LOAD_PATH << File.expand_path("./lib", File.dirname(__FILE__))
require "icloud"
require "./secrets"

desc "Dump reminders"
task :reminders do
  session = ICloud::Session.new($APPLE_ID, $PASSWORD)
  puts session.reminders.all
end

Rake::TestTask.new do |t|
  t.pattern = "test/test_*.rb"
end
