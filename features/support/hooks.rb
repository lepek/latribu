After do |s|
  Timecop.return
  $redis.flushdb unless $redis.nil?
end