class Garage
  include Observable

  def initialize(capacity, accepted_vehicle = Vehicle)
    raise "Must have at least one parking space!" unless capacity > 0
    @capacity = capacity
    @vehicles = []
    @observers = {}
    @accepted_vehicle = accepted_vehicle
  end
  
  def visit(visitor)
    visitor.visited_garage(self)
    visitor
  end
  
  def park(vehicle)
    raise "No spaces left :'(" if full?
    @vehicles << vehicle
    notify_observers
  end

  def exit(vehicle)
    raise "No cars to take :'(" if empty?
    @vehicles.delete(vehicle)
    notify_observers
  end
  
  def include?(vehicle)
    @vehicles.include?(vehicle)
  end
  
  def full?
    @vehicles.count == @capacity
  end
  
  def percent_full
    @vehicles.count / @capacity.to_f * 100
  end

  def empty?
    @vehicles.empty?
  end

  def vehicle_count
    @vehicles.count
  end
  
  def capacity
    @capacity
  end
    
end

Vehicle = Object


ParkingSpace = GarageFloor = Garage