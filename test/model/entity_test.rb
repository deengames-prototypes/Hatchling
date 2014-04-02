require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/model/entity"

class ModelTest < Test::Unit::TestCase
	
	# Real components are not necessary; properties suffice.
	def test_initialize_adds_components
		e = Hatchling::Entity.new({ :name => 'ashes999' })
		assert(e.has?(:name) == true)
		assert(e.has?(:display) == false)
		name = e.get(:name)
		assert_equal('ashes999', name)
	end
	
	def test_entity_accepts_new_components
		e = Hatchling::Entity.new({})
		e.power = 999
		assert_equal(999, e.power)
		assert(e.has?(:power))
	end
	
	def test_entity_raises_for_unknown_property
		e = Hatchling::Entity.new({})
		assert_raise(RuntimeError) { e.speed }
	end
	
	def test_trigger_calls_receive_event_on_call_components_except_exclusion
		called = false
		called_with = nil
		called_on_receiver = false
		
		originator = BaseComponent.new
		receiver = BaseComponent.new
		
		originator.bind("Player Dies", lambda { |data| called = true; called_with = data })
		receiver.bind("Player Dies", lambda { |data| called_on_receiver = true })
		
		e = Hatchling::Entity.new({
			:broadcast => originator,
			:receive => receiver
		})
		
		receiver.trigger("Player Dies", { :source => "Poison" })
		
		assert_equal(true, called)
		assert_equal("Poison", called_with[:source])
		assert_equal(false, called_on_receiver)
	end
end
