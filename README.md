# iCloud for Ruby

This is an extraordinarily crap attempt at Ruby bindings to iCloud. It uses the
wonderful [Mechanize] [mech] to log in to icloud.com and scrape the interesting
bits. So far, I've only implemented read-only access to reminders and alarms.
I'm going to add write access next, so I can script those. After that? Who
knows.

*Warning!! Do not use this for anything even remotely serious. Actually,
probably just don't use it at all. There are no tests, and it's already
destroyed my house and killed two of my dogs and sent all of my money to
NAMBLA.*

[mech]: https://github.com/tenderlove/mechanize


## Notes on Reverse-Engineering iCloud.com

### General

* To start a session, POST an `apple_id`, `password`, and `extended_login=false`
  (as JSON, *not URL encoded*) to `https://setup.icloud.com/setup/ws/1/login`.

* Once logged in, extract and store the `dsid` (Something Session ID?) from the
  `X-APPLE-WEBAUTH-USER` cookie. You'll need it for subsequent requests.

* GUIDs are always upper case, in RFC4122 format.

* All subsequent requests MUST include:

* * The `Origin: www.icloud.com` HTTP header. Mandatory CSRF protection.

* * The `lang=en-us` and `usertz=America/New_York` GET params. Obviously, the
    values changed where appropriate, so long as they're still valid.

* * The `dsid=#{DSIS}` GET param. The value can be found in the
    `X-APPLE-WEBAUTH-USER` cookie, which is set only once, after login.

* Requests made via `icloud.com` include, but do not seem to be mandatory:

* * The `DNT: 1` HTTP header. No idea what this is.

* * The `clientVersion=3.1` and `clientID=#{GUID}` GET params.

* * The `requestID=#{n}` GET param, which simply increments.
