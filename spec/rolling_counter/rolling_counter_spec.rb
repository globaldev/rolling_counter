require "timecop"
require "mock_redis"

require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")

HOUR = 60*60
DAY = 24*HOUR

describe RollingCounter do
  before do
    @max_window = DAY
    @key        = 1
    @redis      = MockRedis.new
    @counter    = RollingCounter.new(@redis, @max_window)
  end

  it "gets the correct count for a 1 hour window" do
    [[2013,7,4,22], [2013,7,5,1], [2013,7,5,3]].each do |time|
      Timecop.freeze(*time) { @counter.incr(@key) }
    end

    Timecop.freeze(2013,7,5,3) { @counter.get(@key, 1*HOUR).should == 1 }
  end

  it "gets the correct count for a 4 hour window" do
    [[2013,7,4,22], [2013,7,5,1], [2013,7,5,3]].each do |time|
      Timecop.freeze(*time) { @counter.incr(@key) }
    end

    Timecop.freeze(2013,7,5,3) { @counter.get(@key, 4*HOUR).should == 2 }
  end

  it "gets the correct count for a day window" do
    [[2013,7,5,1], [2013,7,5,3], [2013,7,5,12], [2013,7,5,23]].each do |time|
      Timecop.freeze(*time) { @counter.incr(@key) }
    end

    Timecop.freeze(2013,7,5,23) { @counter.get(@key, DAY).should == 4 }
  end

  it "gets the correct count for a day window" do
    times = [
      [2013,7,5,1], [2013,7,5,3], [2013,7,5,12], [2013,7,5,23], [2013,7,6,23]
    ]
    times.each do |time|
      Timecop.freeze(*time) { @counter.incr(@key) }
    end

    Timecop.freeze(2013,7,6,23) { @counter.get(@key, DAY).should == 1 }
  end

  it "gets the correct count for a day window" do
    [[2013,7,5,1], [2013,7,5,3], [2013,7,5,12], [2013,7,5,23]].each do |time|
      Timecop.freeze(*time) { @counter.incr(@key) }
    end

    Timecop.freeze(2013,7,5,23) do
      @counter.mget(@key, [4*HOUR, DAY]).should == { 14400 => 1, 86400 => 4 }
    end
  end

end
