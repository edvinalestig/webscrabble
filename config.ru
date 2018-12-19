#used by rackup

#Use bundler to select gems
require 'bundler'

# load all gems in Gemfile
Bundler.require

require_relative 'webapp/app.rb'


run App