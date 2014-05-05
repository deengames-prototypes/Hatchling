require_relative '../test_config'
require_relative "#{SOURCE_ROOT}/component/experience_component"
require_relative "#{SOURCE_ROOT}/system/event_system"
require_relative "#{SOURCE_ROOT}/model/entity"

class ExperienceComponentTest < Test::Unit::TestCase
	
	def test_next_level_at_uses_lambda_from_constructor
		e = ExperienceComponent.new(lambda { |x| return 100*x })
		assert_equal(1, e.level)		
		assert_equal(100 * (e.level + 1), e.next_level_at)
	end
	
	def test_gain_experience_points_increases_level
		e = ExperienceComponent.new(lambda { |x| return 100*x })
		e.gain_experience(200) # 100*level, level=1
		assert_equal(2, e.level)
		assert_equal(300, e.next_level_at)
	end
	
	def test_gaining_levels_triggers_event
		data_seen = nil
				
		e = ExperienceComponent.new(lambda { |x| return 100*x })		
		dummy = Hatchling::Entity.new({:experience => e })
		e.bind(:leveled_up, lambda { |data|
			data_seen = data			
		})
		system = EventSystem.new
		system.init([dummy], nil)
		
		e.gain_experience(200) # 100*level, level=1
		assert_equal(2, e.level)
		assert_equal(1, data_seen[:levels_up])
		assert_equal(2, data_seen[:level])
	end
end
