require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/component/battle_component"
require_relative "#{SOURCE_ROOT}/component/display_component"
require_relative "#{SOURCE_ROOT}/model/entity"

class BattleComponentTest < Test::Unit::TestCase
	
	def test_initialize_sets_strength_and_speed
		b = BattleComponent.new(17, 241, nil)
		assert_equal(17, b.strength)
		assert_equal(241, b.speed)
	end
	
	def test_initialize_raises_if_values_are_non_positive_integers
		assert_raise(RuntimeError) { BattleComponent.new(0, "hi", nil) }
		assert_raise(RuntimeError) { BattleComponent.new(13, -1, nil) }		
	end
	
	def test_pick_move_moves_closer_to_target_on_random_axis
		target = Hatchling::Entity.new({:display => DisplayComponent.new(3, 3, '@', "redz")})
		
		b = BattleComponent.new(1, 1, target);
		d = DisplayComponent.new(5, 5, '@', "bluez");
		
		me = Hatchling::Entity.new({
			:display => d,
			:battle => b
		})
		
		move = b.pick_move
		# Moved closer; one axis only
		assert(move[:x] < 5 || move[:y] < 5)
		assert(move[:x] == 5 || move[:y] == 5)
		repeat_move(b, move)
				
		d.x = 0
		d.y = 0
		
		move = b.pick_move
		# Moved closer; one axis only
		assert(move[:x] > 0 || move[:y] > 0)
		assert(move[:x] == 0 || move[:y] == 0)
		repeat_move(b, move)
	end
	
	def repeat_move(b, move)
		next_move = {:x => move[:x], :y => move[:y]}
		tries = 0
		
		while (next_move[:x] == move[:x] && next_move[:y] == move[:y]) do
			tries += 1
			assert(tries <= 100, "Didn't get two different moves in #{tries} tries")
			next_move = b.pick_move
		end
	end
end
