require 'rubygems'
require 'bundler'

Bundler.require

require './src/config/boot'

run TINYmoirai::Web::Main
