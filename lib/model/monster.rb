class Monster < Entity

	def initialize(x, y, type)
		@type = name.to_s
		first_char = type[0]
		super({ :display => DisplayComponent.new(x, y, first_char, Color.new(0, 255, 0)) })
		
		# TODO: generate stats based on type
		case type
		when :drone
			
		else
			raise "Not sure how to make a monster of type #{type}"
		end
	end
end
