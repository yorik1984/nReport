# SketchUp Extension: Export Reports
# Version: 1.0.0
# License: GNU
# URL: https://github.com/INTITY/nReport

require 'sketchup.rb'
require 'nReport/console.rb'


module Sketchup::Extensions::NReport
	
	class FilterAtt
		
		def attributes
			
			console = Console.new
			console.initialize
			
		end
	end
end

$empty = ["lenx", "lenz"]