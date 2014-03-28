require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/linux/rgb_color_strategy"
require 'ostruct'

# TODO: use real colours. Doesn't change functionality, though.
class RgbColorStrategyTest < Test::Unit::TestCase
	
	def test_get_index_for_returns_sequential_indicies
		fake_display = FakeDisplay.new
		rgb = RgbColorStrategy.new(fake_display)
		first = rgb.get_index_for("black")
		second = rgb.get_index_for("sparkling pink")
		assert_equal(1, first)
		assert_equal(2, second)
	end
	
	def test_get_index_for_raises_with_more_than_256_colours
		fake_display = FakeDisplay.new
		rgb = RgbColorStrategy.new(fake_display)
		
		(1..255).each do |i|
			rgb.get_index_for("Fake colour #{i}")
		end
		
		assert_raise(RuntimeError) { rgb.get_index_for("Fake colour #257") }
	end
	
	
	class FakeDisplay
		def initialize_color(index, color)
		end
	end
end
