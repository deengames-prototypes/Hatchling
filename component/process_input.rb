class ProcessInput
	def initialize(function)
		@function = function
	end
	
	def process(input)
		@function.call(input)
	end
end