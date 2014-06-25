require_relative 'base_component'
require_relative '../system/event_system'

class HealthComponent < BaseComponent
	attr_reader :current_health, :max_health, :regen_percent
	
	def initialize(max_health, regen_percent = nil, event_handlers = {})
		validate(max_health)
		@current_health = max_health
		@max_health = max_health
		@regen_percent = regen_percent || 0
		
		super()
				
		self.bind(:regen, lambda { |data|
			if self.is_alive?
				healing = (@regen_percent * @max_health).to_i
				@current_health += healing			
				@current_health = [@current_health, @max_health].min
			end			
		}) unless @regen_percent.nil?
		
		@on_death = event_handlers[:on_death] unless event_handlers[:on_death].nil?			
	end
	
	def get_hurt(amount)
		validate(amount)
		@current_health = [@current_health - amount, 0].max
		EventSystem.trigger(:died, { :entity => @entity }) if @current_health == 0		
	end
	
	def is_alive?
		return @current_health > 0
	end
	
	# Event that's triggered when you die
	def on_death		
		@on_death.call unless @on_death.nil?		
	end
	
	private
	
	def validate(health)
		raise "Invalid value of #{health}; please specify an integer value" if health.class.name != 'Fixnum'
		raise "Value (#{health}) must be positive" if health <= 0
	end
end
