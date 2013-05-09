load 'deploy'
Dir['vendor/gems/*/recipes/*.rb','vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
require "rubygems"
require "bundler/capistrano"
load 'config/deploy'

