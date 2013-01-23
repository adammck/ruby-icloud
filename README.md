# iCloud Reminders for Ruby

This is a Ruby library to access iCloud reminders.

## Try it

```
$ git clone https://github.com/adammck/ruby-icloud.git
$ cd ruby-icloud
$ bundle --path=vendor --binstubs
$ APPLE_ID="you@icloud.com" APPLE_PW="password" bin/rake reminders

Reminders for Adam Mckaig
1. Disregard females
2. Acquire currency
3. Do laundry
```

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


## Testing

The integration tests hit `icloud.com` for real, so to run them, you should set
up a separate [Apple ID] [appleid] and set the following environment vars:

```
APPLE_ID=
APPLE_PW=
```

For now, you must also manually set up the following reminders:

```
Title: Foo
List: Alpha
Completed: Yes
```

```
Title: Bar
List: Alpha
Completed: Yes
```

```
Title: One
List: Alpha
Completed: No
```

```
Title: Two
List: Alpha
Completed: No
Reminder: 01/02/2015 03:00 PM
```

```
Title: Three
List: Beta
Completed: No
```

I use a totally separate Apple ID for this, because it's entirely possible that
this library will trash your calendar, cancel all of your alarms, turn off your
grandmother's life support, and so on. I'm aware this this is absurd, but I
don't have a better solution right now.


## License

[ruby-icloud] [repo] is free software, available under [the MIT license]
[license].




[repo]:    https://github.com/adammck/ruby-icloud
[license]: https://raw.github.com/adammck/ruby-icloud/master/LICENSE
[appleid]: https://appleid.apple.com
