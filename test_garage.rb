require 'test/unit'
require './observable'
require './garage'
require './employee'
require './parking_complex'
require './percentage_filter'

class TestGarage < Test::Unit::TestCase
  CAPACITY = 100
  def setup
   @garage = Garage.new(CAPACITY)
   @attendant_one = Employee.new
   @garage.register(@attendant_one, PercentageFilter.new(100))
   @vehicle = Vehicle.new
  end

  def test_garage_capacity_is_valid
    assert_raise(RuntimeError) { Garage.new(-1) }
    assert_raise(RuntimeError) { Garage.new(0) }
  end
   
  def test_garage_percentage_calculation_is_correct
   garage = Garage.new(100)
   50.times { garage.park(@vehicle) }
   assert_equal 50, garage.percent_full

   garage = Garage.new(2)
   garage.park(@vehicle)
   assert_equal 50, garage.percent_full
  end

  def test_garages_start_empty
   assert @garage.empty?
  end

  def test_garage_is_full
   CAPACITY.times { @garage.park(@vehicle) }
   assert_equal @garage.full?, true
  end

  def test_cannot_park_when_full
   CAPACITY.times { @garage.park(@vehicle) }
   assert_raise(RuntimeError) { @garage.park(@vehicle) }
  end

  def test_can_park_a_car
   @garage.park(@vehicle)
   assert ! @garage.empty?
  end

  def test_car_can_leave
   @garage.park(@vehicle)
   @garage.exit(@vehicle)
   assert @garage.empty?
  end

  def test_cannot_exit_when_empty
   assert_raise(RuntimeError) { @garage.exit(@vehicle) }
  end

  def test_attendant_notified_when_full
    (CAPACITY-1).times {@garage.park(@vehicle)}
    assert_equal false, @attendant_one.active?

    @garage.park(@vehicle)   
    assert @attendant_one.active?
    
    @garage.exit(@vehicle)
    assert_equal false, @attendant_one.active?
  end

  def test_parking_complex_is_full_when_all_its_garages_are_full
    parking_complex = ParkingComplex.new ParkingComplex::RoundRobinParkingStrategy.new, Garage.new(100), Garage.new(100)
    
    199.times {parking_complex.park(Vehicle.new)}
    assert !parking_complex.full?
    last_car = Vehicle.new

    parking_complex.park(last_car)
    assert parking_complex.full?
    
    parking_complex.exit(last_car)
    assert !parking_complex.full?
  end
  
  def test_parking_complex_raises_an_exception_if_we_try_to_remove_nonexistent_car
    parking_complex = ParkingComplex.new ParkingComplex::RoundRobinParkingStrategy.new, Garage.new(100)
    assert_raise(ParkingComplex::CarNotFoundError) { parking_complex.exit(Vehicle.new) }
  end
  
  def test_parking_complex_raises_an_exception_if_there_is_no_space_left
    parking_complex = ParkingComplex.new ParkingComplex::RoundRobinParkingStrategy.new, Garage.new(1)
    parking_complex.park(Vehicle.new)
    assert_raise(ParkingComplex::NoSpacesLeftError) { parking_complex.park(Vehicle.new) }
  end
  
  def test_parking_complex_observer
    attendant = Employee.new
    parking_complex = ParkingComplex.new(ParkingComplex::RoundRobinParkingStrategy.new, Garage.new(1), Garage.new(1))
    parking_complex.register(attendant, PercentageFilter.new(100))
    assert !attendant.active?
    parking_complex.park(Vehicle.new)
    assert !attendant.active?
    parking_complex.park(Vehicle.new)    
    assert attendant.active?
  end

  def test_round_robin_parking_strategy
    g1, g2 = Garage.new(10), Garage.new(10)
    parking_complex = ParkingComplex.new(ParkingComplex::RoundRobinParkingStrategy.new, g1, g2)
    parking_complex.park(Vehicle.new)
    parking_complex.park(Vehicle.new)
    assert_equal 1, g1.vehicle_count
    assert_equal 1, g2.vehicle_count    
  end

  def test_first_available_parking_strategy
    g1, g2 = Garage.new(10), Garage.new(10)
    parking_complex = ParkingComplex.new(ParkingComplex::FillFirstAvailableParkingStrategy.new, g1, g2)
    parking_complex.park(Vehicle.new)
    parking_complex.park(Vehicle.new)
    assert_equal 2, g1.vehicle_count
    assert_equal 0, g2.vehicle_count    
  end

  def test_equal_percentage_parking_strategy
    g1, g2 = Garage.new(4), Garage.new(100)
    parking_complex = ParkingComplex.new(ParkingComplex::EqualPercentageParkingStrategy.new, g1, g2)
    parking_complex.park(Vehicle.new)
    parking_complex.park(Vehicle.new)
    parking_complex.park(Vehicle.new)
    assert_equal 1, g1.vehicle_count
    assert_equal 2, g2.vehicle_count    
  end

  
  def test_event_coordinator_notified_when_80pct
    event_coordinator = Employee.new
    @garage.register(event_coordinator, PercentageFilter.new(80))
  
    (CAPACITY-21).times { @garage.park(@vehicle) }
    assert !event_coordinator.active?
  
    @garage.park(@vehicle)
    assert event_coordinator.active?
  
    @garage.exit(@vehicle)
    assert !event_coordinator.active?
  end
  
end