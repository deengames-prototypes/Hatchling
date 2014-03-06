includes = ['assets', 'data']

require 'fileutils'
FileUtils.rm_rf('release')
Dir.mkdir('release')

system('ocra lib/hatchling.rb')
FileUtils.cp('hatchling.exe', 'release')
File.delete('hatchling.exe')

includes.each do |i|
	FileUtils.copy_entry(i, "release/#{i}")
end

puts 'Done. Release is published to /release.'