# iCloud Reminders for Ruby

This is a Ruby library to access iCloud reminders.


## Examples

```ruby
# Dump all incomplete reminders.
puts Reminders.select do |r|
  not r.completed?
end
```

```ruby
# Create a new reminder.
Reminders.create "Feed the dog",
  :notes => "If you don't, it will starve to death.",
  :at => DateTime.parse("5:30 PM"),
  :repeat => :daily
```


## License

[rb-icloud-reminders] [repo] is free software, available under [the MIT license]
[license].




[repo]:        https://github.com/adammck/gh-news-feed-filters
[license]:     https://raw.github.com/adammck/gh-news-feed-filters/master/LICENSE
