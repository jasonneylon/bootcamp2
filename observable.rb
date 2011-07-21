module Observable
  
  def notify_observers
    @observers.each { |observer, filter| filter.notify(observer, vehicle_count, capacity) }
  end

  def register(observer, filter)
    @observers[observer] = filter
    notify_observers
  end

end