class CapacityVisitor
  attr_reader :capacity
  
  def initialize
    @capacity = 0
  end
  
  def visited_garage(garage)
    @capacity += garage.capacity
  end
  
  def visited_parking_complex(parking_complex)
  end
  
end
