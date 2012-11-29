#!/usr/bin/env rake
# vim: et ts=2 sw=2

require "rake/testtask"

$LOAD_PATH << File.expand_path("./lib", File.dirname(__FILE__))
require "icloud"

desc "Dump reminders"
task :reminders do
  session = ICloud::Session.new(ENV["APPLE_ID"], ENV["APPLE_PW"], ENV["APPLE_SHARD"])
  puts "Incomplete reminders for #{session.user.full_name}"
  puts session.driver.reminders.map(&:title)
end

Rake::TestTask.new do |t|
  t.pattern = "test/**/test_*.rb"
end
