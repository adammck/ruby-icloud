# iCloud Reminders for Ruby

This is a Ruby library to access iCloud reminders.

## Try it

```sh
git clone https://github.com/adammck/ruby-icloud.git
cd ruby-icloud
bundle --path=vendor
bundle exec irb -r icloud
```

```irb
irb(main):001:0> session = ICloud::Session.new("you@icloud.com", "passw0rd")
=> #<ICloud::Session:0x10637e040>
irb(main):002:0> session.reminders.first(3).map(:title)
=> ["Grocery shopping", "Acquire currency", "Do laundry"]
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


## Compatibility

This gem is [tested against] [travis]:

* Ruby 1.8.7
* Ruby 1.9.2
* Ruby 1.9.3
* Ruby 2.0.0


## License

[ruby-icloud] [repo] is free software, available under [the MIT license]
[license].




[repo]:    https://github.com/adammck/ruby-icloud
[license]: https://raw.github.com/adammck/ruby-icloud/master/LICENSE
[appleid]: https://appleid.apple.com
[travis]:  http://travis-ci.org/adammck/ruby-icloud
