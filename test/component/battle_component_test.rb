require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/component/battle_component"

class BattleComponentTest < Test::Unit::TestCase
	
	def test_initialize_sets_strength_and_speed
		b = BattleComponent.new(17, 241)
		assert_equal(17, b.strength)
		assert_equal(241, b.speed)
	end
	
	def test_initialize_raises_if_values_are_non_positive_integers
		assert_raise(RuntimeError) { BattleComponent.new(0, "hi") }
		assert_raise(RuntimeError) { BattleComponent.new(13, -1) }		
	end
end
