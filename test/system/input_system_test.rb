require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/system/input_system"
require_relative "#{SOURCE_ROOT}/component/input_component"
require_relative "#{SOURCE_ROOT}/component/display_component"
require_relative "#{SOURCE_ROOT}/model/entity"

class InputSystemTest < Test::Unit::TestCase
	
	def setup
		@player = Hatchling::Entity.new({
			:name => 'Player',
			:display => DisplayComponent.new(5, 5, '@', nil)
		})
	end
	
	def test_init_raises_if_player_is_not_found
		e = Hatchling::Entity.new({
			:battle => BattleComponent.new(1, 2, nil),
			:display => DisplayComponent.new(0, 0, '@', nil)
		})
		
		assert_raise(RuntimeError) { InputSystem.new(nil).init([], nil) }
		assert_raise(RuntimeError) { InputSystem.new(nil).init([e], nil) }
		
		player = Hatchling::Entity.new({ :name => 'player'})		
		assert_nothing_raised { InputSystem.new(nil).init([e, player], nil) }
	end
	
	def test_get_and_process_input_returns_target_if_one_exists_and_calls_process_input
		status = :fail
		
		m = Hatchling::Entity.new({
			:display => DisplayComponent.new(5, 4, 'm', :red),
			:input => InputComponent.new(lambda { |i| status = :pass })
		})
		
		i = InputSystem.new(MockKeys)
		i.init([m, @player], nil)
		result = i.get_and_process_input
		assert_equal(m, result[:target])
		assert_equal(:pass, status)
	end
	
	def test_get_and_process_input_moves_player_if_destination_is_empty
		m = Hatchling::Entity.new({
			:display => DisplayComponent.new(50, 14, 'm', :red)
		})
		
		i = InputSystem.new(MockKeys)
		i.init([m, @player], nil)
		result = i.get_and_process_input
		assert_equal(nil, result[:target])
		assert_equal(4, @player.get(:display).y)
	end	
end

class MockKeys
	def self.read_character
		return 'up'
	end
end
