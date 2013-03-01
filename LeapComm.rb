require 'socket'
require 'auto_click'

class Vector
	attr_accessor :x, :y
	def initialize(x, y)
		@x, @y = x, y
	end
end

def getsIO(io)
  begin
    s = ''
    while true
      c = ''
      io.sysread(1, c)
      if (c != "\n")
        s += c
      else
        break
      end
    end
    s
  rescue
    puts "Connection Lost"
    exit
  end
end

puts "Connecting to leap motion program..."
puts "Note, if you do not want to use the leap motion, comment out the require for LeapComm in ParticlePhysics.rb"
$server = TCPSocket.open('localhost', 1998)
puts "Connected"

class Window
	def getPacket
		s = getsIO($server)
		$server.syswrite("Received\n")
		parts = s.split(':')
		a = parts[0].to_i
		action = nil
		action = :pull if a == 1
		action = :push if a == 2
		x = parts[1].to_i
		y = parts[2].to_i
		mouse_move(x,y) if x != -1 && y != -1
		InfoPacket.new(action, mouse_x, mouse_y)
	end
end