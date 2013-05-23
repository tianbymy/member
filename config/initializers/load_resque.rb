require "redis"
require "resque"
require 'redis/namespace'
require 'resque'

#NOTICE 如果 整个 web 项目需要用  redis , 请把 这个文件移到  config/initializers 目录下

resque_config_file = File.join(Rails.root, 'config', 'resque.yml')

if File.file?(resque_config_file)
  resque_config = YAML::load_file(resque_config_file)
  if resque_config.is_a?(Hash) && resque_config.has_key?(Rails.env)
    Resque.redis = resque_config[Rails.env]
  end
end
Resque.redis.namespace = "member"
Redis::Classy.db = Resque.redis
