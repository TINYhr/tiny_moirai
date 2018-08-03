require 'bundler/setup'
require 'sneakers'
require 'bunny'
require 'json'

Bundler.require

if ENV['RACK_ENV'].nil? || %w(development test).include?(ENV['RACK_ENV'])
  require "sinatra/reloader"
  require 'pry'
end

app_dir = File.expand_path("./../", File.dirname(__FILE__))

# require File.join(app_dir, 'config/environment.rb')
# require File.join(app_dir, 'config/application')

lib_files = File.join(app_dir, %w(lib ** *.rb))
model_files = File.join(app_dir, %w(models ** *.rb))
init_files = File.join(app_dir, %w(initializers ** *.rb))
core_files = File.join(app_dir, %w(core ** *.rb))
files = [lib_files, model_files, init_files, core_files]

Dir.glob(files).each {|lf| require lf }

if ENV['RACK_ENV'] == 'production'
  log = File.new("tmp/production.log", "a+")
  $stdout.reopen(log)
  $stderr.reopen(log)
end

config_file = File.join(app_dir, %w(config sneakers.conf.rb))
Sneakers.configure  :runner_config_file => config_file,
                    :amqp => ENV['AMQP_ENDPOINT'],
                    :timeout_job_after => 60,
                    :threads => 5,
                    :workers => 3,
                    :durable => true,
                    :ack => true

listener_files = File.join(app_dir, %w(listeners ** *.listener.rb))
Dir.glob(listener_files).each {|lf| require lf }

module Sneakers
  module ActiveRecord
    module ConnectionManagement
      # https://github.com/jondot/sneakers/issues/302
      # https://github.com/rails/rails/commit/c7b7c6ad1c773102753f1a11b857d0e37ceb6a21
      def process_work(delivery_info, metadata, msg, handler)
        super
      ensure
        ::ActiveRecord::Base.clear_active_connections!
      end
    end
  end
end

module Sneakers
  module Worker
    logger.warn "Patch Sneakers::Worker to clear ActiveRecord connections"
    prepend Sneakers::ActiveRecord::ConnectionManagement
  end
end
