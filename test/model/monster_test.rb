require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/model/monster"

class MonsterTest < Test::Unit::TestCase
	
	def test_initialize_gives_drones_required_components_and_data
		m = Monster.new(10, 13, :drone)
		
		# Check for components
		[:display, :battle, :health].each do |c|
			assert(m.has?(c))
		end		
		
		d = m.get(:display)
		assert_not_nil(d)
		assert_equal(10, d.x)
		assert_equal(13, d.y)
		assert_equal('d', d.character)
		
		b = m.get(:battle)
		assert_not_nil(b)
		assert(b.strength > 1)
		assert(b.speed >= 1)
		
		h = m.get(:health)
		assert_not_nil(h)
		assert(h.max_health > 0)
	end
end
