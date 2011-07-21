class ParkingComplex
  include Observable
  
  
  class RoundRobinParkingStrategy
    
    def initialize
      @index = 0
    end
    
    def next_garage(garages)      
      loop do
        garage = garages[@index]
        @index = (@index + 1) % garages.size
        return garage unless garage.full?
      end
    end
    
  end
  
  class FillFirstAvailableParkingStrategy
    
    def next_garage(garages)
      garages.find {|g| !g.full? }
    end
    
  end
  
  class EqualPercentageParkingStrategy
    
    def next_garage(garages)
      garages.sort {|g| g.percent_full}.first
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
    raise NoSpacesLeftError.new unless spaces_available?    
    @strategy.next_garage(@garages).park(vehicle)
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

  def capacity
    @garages.map(&:capacity).inject(&:+)
  end
  
end