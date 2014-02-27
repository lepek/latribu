After do |s|
  Timecop.return
  $redis.flushdb if $redis.connected?
end