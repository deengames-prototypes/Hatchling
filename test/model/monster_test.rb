require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/model/monster"

class MonsterTest < Test::Unit::TestCase
	
	def test_initialize_gives_drones_required_components_and_data
		m = Monster.new(10, 13, :drone)
		
		# Check for components
		[:display, :strength, :health].each do |c|
			assert(m.has?(c))
		end		
		
		d = m.get(:display)
		assert_not_nil(d)
		assert_equal(10, d.x)
		assert_equal(13, d.y)
		assert_equal('d', d.character)
		
		assert(m.get(:strength) > 0)
		
		h = m.get(:health)
		assert_not_nil(h)
		assert(h.max_health > 0)
	end
end
