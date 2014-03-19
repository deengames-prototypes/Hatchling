tests = Dir.glob('**/*.rb').select { |f|
	# Ignore this file, and our test config file
	next if f == $0 || f == 'test_config.rb'
	f = f[0, f.rindex('.rb')]
	require_relative "#{f}"
}
