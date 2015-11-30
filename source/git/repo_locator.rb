#!/usr/bin/env ruby_silva_wrapper
require 'hive/support/dynamic'
options = Hive::Support::Dynamic.new.options

repo_map = {}
if options[:params].size == 0
  puts YAML.dump(repo_map)
  exit 0
end

Dir.glob("#{options[:params][0]}/**/.git").
    collect{|x| x.slice!(options[:params][0]); x }.
    collect{|x| x.split(File::SEPARATOR)}.
    collect{|x| x.pop; x.shift if x.size > 0 && x[0].empty?; x}.each do |x|
  start_point = repo_map
  x.each do |elem|
    start_point[elem] ||= {}
    start_point = start_point[elem]
  end
  start_point[:repo] = true
end

if options[:path].size == 0
  puts YAML.dump(repo_map)
  exit 0
end

start_point = repo_map
last_elem = options[:path].size - 1
options[:path].size.times do |elem|
  if elem == last_elem
    if start_point.key?(options[:path][elem]) && start_point[options[:path][elem]][:repo]
      target_dir = File.join(options[:params][0],options[:path])
      result = {}
      result[:honeycomb] = "echo '#{target_dir}' > $BEEKEEPER_DIR_CHANGE_REQUEST"
      puts YAML.dump(result)
    else
      puts YAML.dump(start_point.select{|k,v| k.start_with?(options[:path][elem])})
    end
    exit 0
  else
    start_point = start_point[options[:path][elem]]
    break unless start_point
  end
end
