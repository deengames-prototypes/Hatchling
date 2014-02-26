require 'fileutils'
FileUtils.rm_rf('release')
Dir.mkdir('release')
system('ocra main.rb')
FileUtils.cp('main.exe', 'release')
FileUtils.copy_entry('assets', 'release/assets')
File.delete('main.exe')