require "redis_cache.rb"

begin
  if ENV["REDISCLOUD_URL"]
    uri = URI.parse(ENV["REDISCLOUD_URL"])
    $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  else
    $redis = Redis.new
  end
  $redis.ping
  $redis.flushdb
  $redis.connected = true
rescue
  $redis.connected = false
end