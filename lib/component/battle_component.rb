class BattleComponent
	attr_reader :strength, :speed
	
	def initialize(strength, speed)		
		validate(strength, :strength)
		validate(speed, :speed)
		@strength = strength
		@speed = speed
	end
	
	private
	
	def validate(field, name)		
		raise "Invalid value of #{field} for #{name}; please specify an integer value" if field.class.name != 'Fixnum'
		raise "#{name} (#{field}) must be positive" if field <= 0
	end
end
