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
end
