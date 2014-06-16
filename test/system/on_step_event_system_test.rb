require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/system/on_step_event_system"
require_relative "#{SOURCE_ROOT}/model/entity"
require_relative "#{SOURCE_ROOT}/component/display_component"
require_relative "#{SOURCE_ROOT}/component/interaction_component"
include Hatchling

class OnStepEventSystemTest < Test::Unit::TestCase
	
	# Hypothetical, because we don't have two actions on one tile, nor 
	# do we have two entities on a tile. Well, it's okay, just test it.
	def test_check_for_events_triggers_all_events_on_all_entities_there
		target = Entity.new(:display => DisplayComponent.new(3, 3, '@', 'white'))
		other_target = Entity.new(:display => DisplayComponent.new(3, 3, 'q', 'red'))
		non_target = Entity.new(:display => DisplayComponent.new(6, 4, 'b', 'blue'))
		
		horizontally = Entity.new(
			:on_step => InteractionComponent.new(lambda { |e| e.get(:display).x = 7 }),
			:display => DisplayComponent.new(3, 3, '%', 'purple')
		)
		
		vertically = Entity.new(
			:on_step => InteractionComponent.new(lambda { |e| e.get(:display).y = 11 }),
			:display => DisplayComponent.new(3, 3, '?', 'yellow')
		)
		
		system = OnStepEventSystem.new
		system.init([target, other_target, non_target, horizontally, vertically], nil)
		system.check_for_events
		
		# Both targets moved
		assert_equal(7, target.get(:display).x)
		assert_equal(11, target.get(:display).y)
		assert_equal(7, other_target.get(:display).x)
		assert_equal(11, other_target.get(:display).y)
		
		# Some guy far away didn't move
		assert_equal(6, non_target.get(:display).x)
		assert_equal(4, non_target.get(:display).y)
	end
end
