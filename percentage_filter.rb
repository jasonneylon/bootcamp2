class PercentageFilter
  def initialize(percentage)
    @threshold = percentage
    @state = UNKNOWN
  end
  
  UNKNOWN = Proc.new { |filter, observer, threshold, percentage_occupied| state = percentage_occupied >= threshold ? UPPER : LOWER; filter.change_state(state, observer)}
  LOWER = Proc.new { |filter, observer, threshold, percentage_occupied| filter.change_state(UPPER, observer) if percentage_occupied >= threshold }
  UPPER = Proc.new { |filter, observer, threshold, percentage_occupied| filter.change_state(LOWER, observer) if percentage_occupied < threshold }
  
  def notify(observer, car_count, capacity)
    @state.call(self, observer, @threshold, car_count / capacity.to_f * 100)      
  end

  def change_state(to_state, observer)
    @state = to_state
    action = @state == LOWER ? :lower : :upper
    observer.send :"#{action}_notification"
  end
end
