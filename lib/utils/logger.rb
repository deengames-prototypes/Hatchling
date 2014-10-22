require 'logging'

class Logger
  @@logger = nil
  
	def self.init(filename)
		File.delete("#{filename}.log") if File.exists?("#{filename}.log")
		@@logger = Logging.logger['main']
		@@logger.add_appenders(
			#Logging.appenders.stdout,
			Logging.appenders.file("#{filename}.log")
		)
		@@logger.level = :debug
	end
	
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

