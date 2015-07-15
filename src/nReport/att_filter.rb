# SketchUp Extension: Export Reports
# Version: 1.0.0
# License: GNU
# URL: https://github.com/INTITY/nReport

require 'sketchup.rb'
require 'nReport/console.rb'


module Sketchup::Extensions::NReport
	
	class AttFilter
		
		# Attributes
		@att = [
			"name", "summary", "description", "itemcode",	# Component Info
			"lenx", "leny", "lenz",							# Size
			"x", "y", "z",									# Position
			"rotx", "roty", "rotz",							# Rotation
			"Material"										# Behaviors
			]
		
		def attributes
			
			console = Console.new
			console.initialize
			
		end
	end
end
