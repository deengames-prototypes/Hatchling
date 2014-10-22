require_relative 'io/audio_manager'
require_relative 'io/input'
require_relative 'io/display'
require_relative 'utils/color'

require 'ostruct'
require 'json'


# Handles the current screen; gives it the display and any IO that comes in.
class Game

  attr_reader :current_map, :display, :input
  
  @@instance = nil
  @current_screen = nil
  
  def initialize(args = {})
    raise 'Multiple instances of Game constructed' if !@@instance.nil?
    @@instance = self
    @seed = args[:seed] unless args[:seed].nil?
    
    Logger.init('hatchling.log')
    @display = Display.new
    @input = Input.new
  end
  
  def self.instance
    @@instance
  end
  
  def start
    setup_logger = false
    
    begin
      ### Make sure all requires are called before this or the executable will crash      
      exit if defined?(Ocra)      

      user_input = nil
      quit = false
      
      raise 'Call show(screen) before calling start' if @current_screen.nil?
      
      while (!quit) do          
        user_input = @input.read_character
        @current_screen.process(user_input)
        quit = @current_screen.quit?
      end
      
      Logger.info('Normal termination')
    rescue StandardError => e
      Logger.info("Termination by error: #{e}\n#{e.backtrace}") unless !setup_logger        
      raise # Re-raise after cleaning up
    end
  end
  
  def show_screen(instance_or_class, params = {})
    params[:display] = @display if !params.key?(:display)
    
    @current_screen.destroy unless @current_screen.nil? || !@current_screen.respond_to?(:destroy)
    
    if instance_or_class.class == Class
      @current_screen = instance_or_class.new(params) 
    else
      @current_screen = instance_or_class # instance
    end    
  end
  
  private
  
  def note_seed
    @seed ||= srand()
    srand(@seed)
    Logger.info("This is game ##{@seed}")
  end
end

