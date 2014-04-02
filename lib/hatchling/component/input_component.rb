require_relative 'base_component'

class InputComponent < BaseComponent
	def initialize(callback)
		@callback = callback
	end
		
	def process_input(input)		
		@callback.call(input)
	end
end
