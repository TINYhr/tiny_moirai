require 'sinatra'
require 'slim'
require 'bunny'
require 'json'

if ENV['RACK_ENV'].nil? || %w(development test).include?(ENV['RACK_ENV'])
  require "sinatra/reloader"
  require 'pry'
end

app_dir = File.expand_path("./../", File.dirname(__FILE__))

# require File.join(app_dir, 'config/environment.rb')
require File.join(app_dir, 'config/application')

lib_files = File.join(app_dir, %w(lib ** *.rb))
model_files = File.join(app_dir, %w(models ** *.rb))

init_files = File.join(app_dir, %w(initializers ** *.rb))
core_files = File.join(app_dir, %w(core ** *.rb))
web_files = File.join(app_dir, %w(web ** *.rb))

files = [lib_files, model_files, init_files, core_files, web_files]

Dir.glob(files).each {|lf| require lf }

configure do
  set :server, :thin
end
