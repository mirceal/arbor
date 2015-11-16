#!/usr/bin/env ruby_beekeeper_wrapper
require 'hive/support/dynamic'
options = Hive::Support::Dynamic.new.options
result = {}

version = RUBY_VERSION.split('.').map(&:to_i)
if (version[0] == 1) && (version[1] < 9)
  ## Random implentation that can be used with 1.8.7
  class Random
    def initialize(seed)
      srand(seed)
    end

    def rand(upper_limit)
      Kernel.rand(upper_limit)
    end
  end
end

if options[:path].size == 3 && options[:path][2].size == 3
  result[:honeycomb] = "echo '#{options[:path].join('-')} battlecruiser operational'"
  puts YAML.dump(result)
  exit 0
end

if options[:path].size < 4
  sum = options[:params][0].to_i if options[:params].size > 0
  sum ||= 0
  options[:path].each { |x| sum += x.to_i if x.size == 3 }
  rnd = Random.new(sum)
  3.times do
    result[rnd.rand(100).to_s.rjust(3, '0').to_s] = 1
  end
  puts YAML.dump(result)
end
