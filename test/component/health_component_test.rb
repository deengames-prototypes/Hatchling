require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/component/health_component"

class HealthComponentTest < Test::Unit::TestCase
	
	def test_initialize_sets_current_and_max_health
		h = HealthComponent.new(100)
		assert_equal(100, h.current_health)
		assert_equal(100, h.max_health)
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
end
