#!/usr/bin/env ruby_silva_wrapper
require 'yaml'
require 'fileutils'
require 'ssh/ident'
require 'hive/support/dynamic'
support = Hive::Support::Dynamic.new
options = support.options
result = {}

begin
  result =  {'build' => 1} if options[:path].size == 0
  if options[:path].size == 1 && options[:path][0].eql?('build')
    fail 'missing identity' unless options[:params].key?(:identity) && options[:params][:identity].is_a?(String)
    fail 'missing keys' unless options[:params].key?(:keys) && options[:params][:keys].is_a?(Array)
    ssh_agent_dir = options[:params]['agent_dir']
    ssh_agent_dir ||= 'ssh_agent'
    ENV['DIR_IDENTITIES'] = File.join(ENV['SILVA_BASE_DIR'], ssh_agent_dir, 'identities')
    ENV['DIR_AGENTS'] = File.join(ENV['SILVA_BASE_DIR'], ssh_agent_dir, 'agents')
    ssh_agent_dir = File.join(ENV['SILVA_BASE_DIR'], ssh_agent_dir, 'identities', options[:params][:identity])
    FileUtils.mkdir_p(ssh_agent_dir) unless File.exist?(ssh_agent_dir)
    options[:params][:keys].each do |key|
      key_name = File.basename(key)
      target_key = File.join(ssh_agent_dir, key_name)
      unless File.exist?(target_key)
        FileUtils.cp key, ssh_agent_dir
        FileUtils.chmod 0400, target_key
      end
    end
    agent_file = nil
    support.capture_stdout do
      agent_file = SSH::Ident::AgentManager.new(:identity => options[:params][:identity]).agent_file
    end
    result[:honeycomb] = "echo 'built ssh_agent with ident #{options[:params][:identity]}, #{agent_file}'"
  end
rescue StandardError => se
  result[:honeycomb] = "echo '#{$0} :: error: #{se.message}'"
end

puts YAML.dump(result)