require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/utils/color"
require_relative "#{SOURCE_ROOT}/windows/dos_color_strategy"
require 'ostruct'

class DosColorStrategyTest < Test::Unit::TestCase
	
	def test_get_index_for_returns_closest_dos_color
		dos = DosColorStrategy.new
		# Expect red (#12) or dark red (#4)
		assert_equal(12, dos.get_index_for(Color.new(255, 0, 0)))
		assert_equal(12, dos.get_index_for(Color.new(243, 0, 0)))
		assert_equal(12, dos.get_index_for(Color.new(193, 0, 0)))
		# Midway between dark and light; rounds up to light
		assert_equal(12, dos.get_index_for(Color.new(192, 0, 0)))
		# Past the tipping point
		assert_equal(4, dos.get_index_for(Color.new(191, 0, 0)))
	end
	
end
