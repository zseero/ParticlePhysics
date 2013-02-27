require 'rubygems'
require 'gosu'

$colors = [
	0xffffffff,#white
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

class Window < Gosu::Window
  def initialize(dimX, dimY)
    super(Gosu::screen_width, Gosu::screen_height, true, 0)
    self.caption = "Particle Physics"
    @dimX, @dimY = dimX, dimY
    makeParticles
  end

  def makeParticles
    x = 0
    xSpace = width / @dimX
    ySpace = height / @dimY
    @particles = []
    while x < width
    	y = 0
    	while y < height
    		@particles << Particle.new(self, x, y, (height * 0.5).round)
    		y += ySpace
    	end
    	x += xSpace
    end
  end

  def needs_cursor?
  	true
  end

  def update
  	@particles.each do |particle|
  		particle.update
  	end
	end

  def draw
  	color = $colors[0]
  	draw_quad(0, 0, color, width, 0, color, width, height, color, 0, height, color, Layers::Background)
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
	def initialize(window, x, y, radius = 500)
		@window = window
		@origX = x
		@origY = y
		@x = x
		@y = y
		@velX = @velY = 0.0
		@radius = radius
		@color = $colors[Random.rand(1...$colors.length)]
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

	def velUpdate
		difX = findLeastDiff(@window.mouse_x, @x, @window.width)
		difY = findLeastDiff(@window.mouse_y, @y, @window.height)
		distance = dist(difX, difY)
		newD = @radius - distance.abs
		bool = newD > 0
		left = @window.button_down?(Gosu::MsLeft)
		right = @window.button_down?(Gosu::MsRight)
		multFactor = newD / (@radius / 0.01)
		if left
			multFactor *= -1
		elsif right
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
	end

	def update
		velUpdate
		@x += @velX
		@y += @velY
		@x %= @window.width
		@y %= @window.height
	end

	def draw
		size = 4
		@window.draw_quad(@x, @y, @color, @x + size, @y, @color, @x + size, @y + size, @color, @x, @y + size, @color, Layers::Pixels)
	end
end

num = 25
window = Window.new(num, num)
window.show