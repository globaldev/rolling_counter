require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
  add_filter { |file| file.source.join !~ /def/ }
end

require "rspec"
require "rspec/autorun"

require "rolling_counter"
