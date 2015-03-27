# RollingCounter

[![Travis build status][badge]][travis]

[badge]: http://img.shields.io/travis/globaldev/rolling_counter.svg
[travis]: https://travis-ci.org/globaldev/rolling_counter

A Redis-based rolling counter with customisable windows.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rolling_counter"
```

And then execute:

```sh
bundle
```

Or install it yourself as:

```sh
gem install rolling_counter
```

## Usage

### Basic Usage

Basic usage of RollingCounter is very simple, and revolves around the methods
`#inc` to increment a count, and `#get` to retrieve a count for a given
time window.

```ruby
require "redis"
require "rolling_counter"

max_window = 60  # the maximum timeframe in seconds over which to count
counter    = RollingCounter.new(Redis.current, max_window)
key        = "my-counter"

counter.inc(key)    #=> 1
sleep 2
counter.inc(key)    #=> 2

# Query counts using `max_window` as the time window
counter.get(key)    #=> 2

# Query counts over a custom time window (in seconds)
counter.get(key, 1) #=> 1
```

### Multiple Counters

A single counter can be used to count multiple keys, as long as the required
`max_window` is the same for each.

```ruby
keys = %w{ key1 key2 key3 }
100.times { counter.inc(keys.sample) }

keys.collect { |key| [key, counter.get(key)] }
#=> [["key1", 40], ["key2", 31], ["key3", 29]]
```

Do not attempt to use counters with a different `max_window` to access the same
keys, as results may be inconsistent. Instead set `max_window` to the max
window needed, then pass the window required to `#get`.

### Multiple Windows

Using the binary arity version of `#get(key, window)`, it's possible to track
counts over different windows for the same key.  A use case for this might be
a request rate-limiter which allows burts of requests over a short time period,
but still has a limit over a longer window.

```ruby
class RateLimiter
  def initialize(redis, windows)
    @redis      = redis
    @windows    = windows
    @max_window = windows.keys.max
    @key        = rand(36**20).to_s(36) # use a random key name
  end

  def inc
    counter.inc(@key)
  end

  def limited?
    # We can use #mget to atomically get counts for multiple windows
    counts = counter.mget(@key, @windows.keys)
    @windows.any? { |window, cap| counts[window] >= cap }
  end

  private

  def counter
    @counter ||= RollingCounter.new(@redis, @max_window)
  end
end

# Define a limiter with two windows: 10 in one second, or 15 in 5 seconds
limiter = RateLimiter.new(Redis.current, { 1 => 10, 5 => 15 })

9.times { limiter.inc }
limiter.limited?         #=> false
limiter.inc              #=> 10
limiter.limited?         #=> true (hit the "10 in 1 second" cap)

sleep 2
limiter.limited?         #=> false

5.times { limiter.inc }
limiter.limited?         #=> true (hit the "15 in 5 seconds" cap)
```

This example could be trivially extended to provide the ability to track
multiple counters, for example to track and limit individual API key usage.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
