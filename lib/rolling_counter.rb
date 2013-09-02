require "rolling_counter/version"
require "securerandom"

class RollingCounter

  # :call-seq: RollingCounter.new(redis_client, max_window) -> counter
  #
  # Create a new counter instance, that will store/retrieve counts with
  # +redis_client+ and return counts within the last +max_window+ seconds.
  #
  # Do not attempt to use counters with different +max_window+ to access the
  # same keys, as results will not be consistent. Instead set +max_window+ to
  # the max window needed, then pass the window required to #get.
  #
  def initialize(redis, max_window)
    @redis      = redis
    @max_window = max_window
  end

  # :call-seq: counter.incr(key) -> count
  #            counter.incr(key, window) -> count
  #
  # Increment the counter for +key+ by 1. Returns the updated count within
  # +window+, or the +max_window+ if +window+ is not supplied.
  #
  def incr(key, window=@max_window)
    key = key.to_s
    now = Time.now.to_f
    @redis.multi do
      @redis.zadd(key, now, SecureRandom.uuid)
      @redis.expire(key, @max_window.ceil)
      do_get(key, now, window)
    end.last
  end
  alias increment incr
  alias inc incr

  # :call-seq: counter.get(key) -> count
  #            counter.get(key, window) -> count
  #
  # Returns the count for +key+ within +window+ seconds.
  #
  def get(key, window=@max_window)
    @redis.multi { do_get(key.to_s, Time.now.to_f, window) }.last
  end

  # :call-seq: counter.mget(key, [windows]) -> {window:count}
  #
  # Returns a hash of each +windows+ count for +key+.
  #
  def mget(key, windows)
    now = Time.now.to_f
    results = @redis.multi do
      windows.each { |window| do_get(key.to_s, now, window) }
    end.each_slice(2).map(&:last)
    Hash[windows.zip(results)]
  end

  private

  def do_get(key, now, window)
    @redis.zremrangebyscore(key, 0, now - @max_window)
    @redis.zcount(key, now - window, now)
  end
end
