# This installs all gems required to run the game.
# Currently, there are none :)
required = ['json', 'logging']
required << 'win32-sound' if !RUBY_PLATFORM.include?('linux')

required.each do |gem|
	puts "Installing #{gem} ..."
	`gem install #{gem}`
end

if !RUBY_PLATFORM.include?('linux') then
	`gem install win32-sound`
end