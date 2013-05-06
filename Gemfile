source 'http://ruby.taobao.org'
gem 'rails', '3.2.13'
gem 'sqlite3'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'capistrano'

gem 'zhiyi-member', :git => 'git@github.com:zhiyisoft/zhiyi-ldap-member.git'
gem "slim"
gem 'execjs'
gem 'thin'
gem 'cells'
gem 'simple_form'
#gem 'simple_form-bootstrap'
gem 'rubycas-client'
gem 'font-awesome-rails'
gem 'carrierwave-mongoid','~>0.3.0', :require => 'carrierwave/mongoid'
gem 'mongoid'

gemfile_local = File.join(File.dirname(__FILE__), 'Gemfile.local')

if File.readable?(gemfile_local)
  gem "zhiyi-bootstrap-rails", :require => "bootstrap-rails",:path =>"../zhiyi-bootstrap-rails"
else
  gem "zhiyi-bootstrap-rails", :require => "bootstrap-rails", :git => "git@github.com:zhiyisoft/bootstrap-rails.git", :ref => "HEAD"
end


