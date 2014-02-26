require 'fileutils'
FileUtils.rm_rf('release')
Dir.mkdir('release')
system('ocra test.rb')
FileUtils.cp('test.exe', 'release')
FileUtils.copy_entry('assets', 'release/assets')
File.delete('test.exe')