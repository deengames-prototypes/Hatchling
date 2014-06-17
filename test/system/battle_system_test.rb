require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/system/battle_system"
require_relative "#{SOURCE_ROOT}/component/battle_component"
require_relative "#{SOURCE_ROOT}/component/display_component"
require_relative "#{SOURCE_ROOT}/model/entity"

class BattleSystemTest < Test::Unit::TestCase
	
	def setup
		@player = Hatchling::Entity.new({
			:name => 'Player',
			:display => DisplayComponent.new(5, 5, '@', nil),
			:health => HealthComponent.new(10)
		})
	end
	
	def test_init_raises_if_player_is_not_found
		e = Hatchling::Entity.new({
			:battle => BattleComponent.new({:strength => 1, :speed => 2}),
			:display => DisplayComponent.new(0, 0, '@', nil)
		})
		
		assert_raise(RuntimeError) { BattleSystem.new.init([], {}) }
		assert_raise(RuntimeError) { BattleSystem.new.init([e], {}) }
		
		player = Hatchling::Entity.new({ :name => 'player'})
		
		assert_nothing_raised { BattleSystem.new.init([e, @player], {}) }
	end
	
	# TODO: More testing. Events are coming, so wait for that.
	
	def test_is_valid_move_returns_true_for_empty_space
		b = BattleSystem.new
		b.init( [@player], {})
		assert_equal(true, b.is_valid_move?({ :x => 3, :y => 7 }))
	end
	
	def test_is_valid_move_returns_false_if_map_is_valid_move_returns_false
		b = BattleSystem.new
		b.init( [@player], {:current_map => SolidMap.new})
		assert_equal(false, b.is_valid_move?({ :x => 3, :y => 7 }))
	end
	
	def test_is_valid_move_returns_false_if_player_is_there
		b = BattleSystem.new
		b.init( [@player], {})
		assert_equal(false, b.is_valid_move?({ :x => 5, :y => 5 }))
	end	
	
	def test_process_triggers_on_move_events_if_they_exist
		target = Hatchling::Entity.new({:display => DisplayComponent.new(3, 3, '@', "red")})		
		pass = false
		
		# Requirements for triggering on-move:
		# 1) Battle component with on_move lambda
		# 2) Health component + alive
		me = Hatchling::Entity.new({
			:display => DisplayComponent.new(2, 2, '@', "blue"),
			:battle => BattleComponent.new(
				{:strength => 1, :speed => 1, :target => target},
				:on_move => lambda { |x| pass = true }),
			:health => HealthComponent.new(10)
		})
		
		b = BattleSystem.new
		b.init( [target, me, @player], {:current_map => OpenMap.new})
		b.process({:key => 'right'})
		
		assert_equal(true, pass)
	end
	
end

class SolidMap	
	def is_valid_move?(m)
		return false
	end
end

class OpenMap
	def is_valid_move?(m)
		return true
	end
end
