#!/usr/bin/env rake
# vim: et ts=2 sw=2

require "rake/testtask"

$LOAD_PATH << File.expand_path("./lib", File.dirname(__FILE__))
require "icloud"

desc "Dump reminders"
task :reminders do
  session = ICloud::Session.new(ENV["APPLE_ID"], ENV["APPLE_PW"])
  puts "Reminders for #{session.user.full_name}"
  session.reminders.each_with_index do |reminder, i|
    puts "#{i+1}. #{reminder.title}"
  end
end

Rake::TestTask.new do |t|
  t.pattern = "test/**/test_*.rb"
end
