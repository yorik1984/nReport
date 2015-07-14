# SketchUp Extension: Export Reports
# Version: 1.0.0
# License: GNU
# URL: https://github.com/INTITY/nReport

require 'sketchup.rb'



module Sketchup::Extensions::NReport
	
	class Console
				
		def initialize
			
			# Configuration dialog
			title = "Attribute Filter"
			scrollable = false
			pref_key = "NREPORT"
			width = 400
			height = 400
			left = 0
			top = 0
			resizable = true
			
			html = File.dirname(__FILE__) + '/html/console.html'
			
			dialog = UI::WebDialog.new(title, scrollable, pref_key, width, height, left, top, resizable);
			dialog.set_file(html, nil)
			dialog.min_width = width
			dialog.min_height = height
			dialog.show
			
		end
	end
end