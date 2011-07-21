class Employee

  def initialize
    @active = nil
  end

  def active?
    @active
  end

  def upper_notification
    @active = true
  end

  def lower_notification
    @active = false
  end

end