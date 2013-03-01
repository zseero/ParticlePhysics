require 'rubygems'
require 'gosu'

$colors = [
	0xffffffff,#white
	0xff000000,#black
  0xffff0000,#red
  0xffff8800,#orange
  0xffffff00,#yellow
  0xff00ff00,#green
  0xff00ffff,#aqua
  0xff0000ff,#blue
  0xffff00ff #purple
]

module Layers
	Background, Pixels = *0...2
end

class InfoPacket
	attr_accessor :action, :x, :y
	def initialize(action, x, y)
		@action = action
		@x = x
		@y = y
	end
end

class Window < Gosu::Window
  def initialize(dimX, dimY)
    super(Gosu::screen_width, Gosu::screen_height, true, 0)
    self.caption = "Particle Physics"
    @dimX, @dimY = dimX, dimY
    makeParticles
  end

  def makeParticles
    x = 1
    xSpace = width / @dimX
    ySpace = height / @dimY
    @particles = []
    i = 0
    while x < width
    	y = 1
    	while y < height
    		index = i / 3
    		index %= $colors.length - 2
    		index += 2
    		@particles << Particle.new(self, x, y, (height * 0.5).round, $colors[index])
    		y += ySpace
    		i += 1
    	end
    	x += xSpace
    end
  end

  def needs_cursor?
  	true
  end

  def getPacket()
  	action = nil
  	action = :pull if button_down?(Gosu::MsLeft)
  	action = :push if button_down?(Gosu::MsRight)
  	packet = InfoPacket.new(action, mouse_x, mouse_y)
  end

  def update
  	packet = getPacket
  	@particles.each do |particle|
  		particle.update(packet)
  	end
	end

  def draw
  	color = $colors[1]
  	draw_quad(0, 0, color,
  						width, 0, color,
  						width, height, color,
  						0, height, color,
  						Layers::Background)
  	@particles.each do |particle|
  		particle.draw
  	end
  end

  def button_down(id)
  	if id != Gosu::MsLeft && id != Gosu::MsRight
  		makeParticles
  	end
  	if id == Gosu::KbEscape
  		exit
  	end
  end
end

class Particle
	def initialize(window, x, y, radius = 500, color = $colors[Random.rand(1...$colors.length)])
		@window = window
		@origX = x
		@origY = y
		@x = x
		@y = y
		@velX = @velY = 0.0
		@radius = radius
		@color = color
		@red = 0x0
		@green = 0x0
		@blue = 0xf
		@max = 10
	end

	def dist(difX, difY)
		Math.sqrt(difX ** 2 + difY ** 2)
	end

	def findLeastDiff(m, c, screen)
		num = (screen - 2) / 2
		r = c - m
		r += screen if r < num
		r -= screen if r > num
		r
	end

	def makeColor(dist)
		num = ((dist.abs / (@window.width / 2)) * 16)
		if num >= 9
			num = 9
		end
		num.round.to_s.to_i(16)
	end

	def velUpdate(packet)
		difX = findLeastDiff(packet.x, @x, @window.width)
		difY = findLeastDiff(packet.y, @y, @window.height)
		distance = dist(difX, difY)
		newD = @radius - distance.abs
		bool = newD > 0
		multFactor = newD / (@radius / 0.01)
		if packet.action == :pull
			multFactor *= -1
		elsif packet.action == :push
			multFactor *= 1
		else
			multFactor *= 0
		end
		if bool && multFactor != 0
			@velX += difX * multFactor 
			@velY += difY * multFactor
		else
			origDifX = findLeastDiff(@origX, @x, @window.width)
			origDifY = findLeastDiff(@origY, @y, @window.height)
			multFactor = -0.0005
			@velX += origDifX * multFactor
			@velY += origDifY * multFactor
		end
		friction = 0.98
		@velX *= friction
		@velY *= friction
		max = 30.0
		@red = makeColor(distance)
		@green = makeColor((@window.width / 2) - distance)
	end

	def update(packet)
		velUpdate(packet)
		@x += @velX
		@y += @velY
		@x %= @window.width
		@y %= @window.height
	end

	def draw
		color = @color#"ff#{@red.to_s(16)}0#{@green.to_s(16)}0#{@blue.to_s(16)}0".to_i(16)
		size = 4
		@window.draw_quad(@x, @y, color,
											@x + size, @y, color,
											@x + size, @y + size, color,
											@x, @y + size, color,
											Layers::Pixels)
	end
end

#require_relative 'LeapComm'

num = 20
window = Window.new(num, num)
window.show