require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/system/event_system"
require_relative "#{SOURCE_ROOT}/model/entity"

class EventSystemTest < Test::Unit::TestCase
	
	def test_trigger_triggers_event_on_all_entities
		components = []
		saw_it = []
		entities = []
		
		(0..1).each do |i|
			b = BaseComponent.new
			b.bind('Calculated PI', lambda { |data|
				saw_it[i] = true			
			})
			saw_it[i] = false
			components << b
			
			entities << Hatchling::Entity.new({ :basic => b })
		end
		
		EventSystem.new.init(entities, nil)
		EventSystem.trigger('Calculated PI', 3.141592654)
				
		(0..saw_it.length - 1).each do |i|
			assert(saw_it[i] == true, "Component #{i} didn't see the event")
		end
	end
end
