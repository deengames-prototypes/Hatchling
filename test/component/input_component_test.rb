require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/component/input_component"

class InputComponentTest < Test::Unit::TestCase
	
	def test_process_input_sends_input_to_callback
		actual = :fail
		i = InputComponent.new(lambda { |input| actual = input })
		i.process_input(:pass)
		assert_equal(:pass, actual)
	end
	
end
