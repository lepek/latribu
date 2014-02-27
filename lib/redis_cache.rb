class Redis

  EXPIRE = 3600

  def connected=(status)
    @connected = status
  end

  def connected?
    @connected
  end

  def cache(params)
    key = params[:key] || raise(ArgumentError, ":key parameter is required!")
    expire = params[:expire] || EXPIRE
    recalculate = params[:recalculate] || nil
    timeout = params[:timeout] || 0
    default = params[:default] || nil

    if ( self.connected? && (value = get(key)).nil? ) || recalculate

      begin
        value = Timeout::timeout(timeout) { yield(self) }
      rescue Timeout::Error
        value = default
      end

      if self.connected?
        set(key, value)
        expire(key, expire) if expire
      end

      value
    else
      value
    end
  end

end