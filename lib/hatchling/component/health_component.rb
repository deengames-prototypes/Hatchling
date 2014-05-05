require_relative 'base_component'
require_relative '../system/event_system'

class HealthComponent < BaseComponent
	attr_reader :current_health, :max_health
	
	def initialize(max_health)
		validate(max_health)
		@current_health = max_health
		@max_health = max_health
		super()
	end
	
	def get_hurt(amount)
		validate(amount)
		@current_health = [@current_health - amount, 0].max
		EventSystem.trigger(:died, { :entity => @entity })
	end
	
	def is_alive?
		return @current_health > 0
	end
	
	private
	
	def validate(health)
		raise "Invalid value of #{health}; please specify an integer value" if health.class.name != 'Fixnum'
		raise "Value (#{health}) must be positive" if health <= 0
	end
end
