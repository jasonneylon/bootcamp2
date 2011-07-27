class ParkingComplex
  include Observable
  
  
  class RoundRobinParkingStrategy
    
    def initialize
      @index = 0
    end
    
    def next_garage(garages, vehicle)      
      (garages.size + 1).times do
        garage = garages[@index]
        @index = (@index + 1) % garages.size
        return garage unless garage.full?
      end
    end
    
  end
  
  class FillFirstAvailableParkingStrategy
    
    def next_garage(garages, vehicle)
      garages.find {|g| !g.full? }
    end
    
  end
    
  class CarNotFoundError < RuntimeError 
  end
  
  class NoSpacesLeftError < RuntimeError 
  end  
  
  def initialize(strategy, *garages)
    @strategy = strategy
    @garages = garages
    @observers = {}
  end
  
  def park(vehicle)
    raise NoSpacesLeftError.new if full?
    garage = @strategy.next_garage(@garages, vehicle)
    garage.park(vehicle)
    notify_observers
  end
  
  def exit(vehicle)
    @garages.find(lambda {raise CarNotFoundError.new }) {|g| g.include?(vehicle) }.exit(vehicle)
    notify_observers
  end
    
  def full?
    @garages.all? {|g| g.full? }
  end
  
  def spaces_available?
    !full?
  end
  
  def vehicle_count
    @garages.map(&:vehicle_count).inject(&:+)
  end

  # def capacity
  #   @garages.map(&:capacity).inject(&:+)
  # end
  
  def capacity
    visit(CapacityVisitor.new).capacity
  end

  def visit(vistor)
    vistor.visited_parking_complex(self)
    @garages.each {|g| g.visit(vistor)}
    vistor
  end
end