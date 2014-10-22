# An interface for screens. Subclass this for your screens.  
class Screen

  # Sets the display to draw to. This is required.
  # Classes are constructed automatically.
  def initialize(params = { })
    params[:display] = Display.instance if !params.key?(:display)
    @display = params[:display]
  end
  
  def process(input)
    # Actual processing logic goes here.
    # Fill this out in your implementation subclasses.
    @last_key = input
  end
  
  def quit?
    return ['q', 'escape'].include?(@last_key)
  end
  
  def destroy
    # Clean up anything that needs to be destroyed/torn-down
  end
end
