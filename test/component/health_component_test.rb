require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/component/health_component"
require_relative "#{SOURCE_ROOT}/model/entity"

class HealthComponentTest < Test::Unit::TestCase
	
	def test_initialize_sets_current_and_max_health_and_zero_regen
		h = HealthComponent.new(100)
		assert_equal(100, h.current_health)
		assert_equal(100, h.max_health)
		assert_equal(0, h.regen_percent)
	end
	
	def test_initialize_raises_if_health_is_non_positive_integers
		assert_raise(RuntimeError) { HealthComponent.new("hi") }
		assert_raise(RuntimeError) { HealthComponent.new(0) }
		assert_raise(RuntimeError) { HealthComponent.new(-17) }		
	end
	
	def test_get_hurt_decreases_current_health
		h = HealthComponent.new(20)
		h.get_hurt(3)
		assert_equal(17, h.current_health)
		assert_equal(20, h.max_health)
	end
	
	def test_get_hurt_decreases_health_to_zero_not_more
		h = HealthComponent.new(20)
		h.get_hurt(3000)
		assert_equal(0, h.current_health)
	end
	
	def test_get_hurt_raises_if_not_given_positive_integers
		h = HealthComponent.new(20)
		assert_raise(RuntimeError) { h.get_hurt(0) }
		assert_raise(RuntimeError) { h.get_hurt(-1) }
		assert_raise(RuntimeError) { h.get_hurt("hi") }
	end
	
	def test_is_alive_is_true_with_any_positive_health
		h = HealthComponent.new(20)
		h.get_hurt(18)
		assert_equal(true, h.is_alive?)
		h.get_hurt(1)
		assert_equal(true, h.is_alive?)
		h.get_hurt(1)
		assert_equal(false, h.is_alive?)
		h.get_hurt(1)
		assert_equal(false, h.is_alive?)
	end
	
	def test_get_hurt_triggers_died_event_on_death
		data_seen = nil
				
		h = HealthComponent.new(20)
		
		dummy = Hatchling::Entity.new({:health => h })
		h.bind(:died, lambda { |data|
			data_seen = data			
		})
		system = EventSystem.new
		system.init([dummy], nil)
		
		h.get_hurt(200)		
		assert_equal(dummy, data_seen[:entity])		
	end
	
	def test_regen_event_triggers_health_regeneration
		h = HealthComponent.new(20, 1)
		h.get_hurt(5)
		e = EventSystem.new
		e.init([Hatchling::Entity.new({ :health => h })], {})
		EventSystem.trigger(:regen, nil)
		assert_equal(1, h.regen_percent)
		assert_equal(20, h.current_health)
	end
	
	def test_regen_event_does_nothing_if_dead
		h = HealthComponent.new(20, 1)
		h.get_hurt(25)
		e = EventSystem.new
		e.init([Hatchling::Entity.new({ :health => h })], {})
		EventSystem.trigger(:regen, nil)		
		assert_equal(0, h.current_health)
	end
end
