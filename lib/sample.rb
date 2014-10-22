require './screen'
require './game'

class DrawIoScreen < Screen
  def process(input)
    super(input)
    @display.draw(0, 0, input)
  end
end

g = Game.new
g.show_screen(DrawIoScreen)
g.start
