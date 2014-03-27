# Used to keep relative paths DRY
require 'test/unit'
TEST_ROOT = Dir.pwd
Dir.chdir("#{Dir.pwd}/../lib/hatchling")
SOURCE_ROOT = Dir.pwd

require_relative '../lib/hatchling'