require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/component/display_component"

class DisplayComponentTest < Test::Unit::TestCase
	
	def test_move_changes_x_and_y_if_set
		d = DisplayComponent.new(13, 27, '@', "color goes here")
		assert_equal(13, d.x)
		assert_equal(27, d.y)
		assert_equal('@', d.character)
		assert_equal("color goes here", d.color)
		
		d.move({ :x => 1, :y => 2 })
		assert_equal(1, d.x)
		assert_equal(2, d.y)		
	end
	
end
