require 'logging'

class Logger
	def self.init
		@@logger = Logging.logger['main']
		@@logger.add_appenders(
			#Logging.appenders.stdout,
			Logging.appenders.file('hatchling.log')
		)
		@@logger.level = :info
	end
	
	init
	
	def self.info(message)
		message = annotate(message)
		@@logger.info(message)
	end
	
	def self.debug(message)
		message = annotate(message)
		@@logger.debug(message)
	end
	
	def self.annotate(message)
		"#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}  #{message}"
	end
end