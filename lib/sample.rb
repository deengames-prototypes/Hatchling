require './screen'
require './game'

class DrawIoScreen < Screen
  def process(input)
    super(input)
    @display.draw(0, 0, input)
  end
end

g = Game.new

# Create by class
#g.show_screen(DrawIoScreen)

# Create by instance
 g.show_screen(DrawIoScreen.new)

g.start
