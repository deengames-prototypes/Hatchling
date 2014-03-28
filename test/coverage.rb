require 'simplecov'
excludes = ['all.rb', 'coverage.rb', 'test_config.rb']

SimpleCov.start do	
	filters.clear
	add_filter do |src|	
		# nil/false is included, everything else is not
		just_file_name = src.filename[src.filename.rindex('/') + 1, src.filename.length].strip			
		if (src.filename =~ /lib\/hatchling/) && !excludes.include?(just_file_name)			
			nil
		else			
			true
		end		
	end		
end

require_relative 'all'
