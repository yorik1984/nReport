# SketchUp Extension: Export Reports
# Version: 1.0.0
# License: GNU
# URL: https://github.com/INTITY/nReport

require 'nReport/core.rb'

module Sketchup::Extensions::NReport

	PUBLIC_LICENSE = 'https://github.com/INTITY/nReport/blob/master/LICENSE'
	core = Core.new

	# Check our extension license and add our menu item only if we are licensed.
	ext_id = 'D8E576C8-1A12-432C-87F0-F7435A5A1457'
	ext_lic = Sketchup::Licensing.get_extension_license(ext_id)
	if ext_lic.licensed?
		# Our extension is licensed, add our UI elements
		menu = UI.menu('Extensions').add_submenu('nReport')
		menu.add_item('Generate Report') { core.generate_report }
		menu.add_item('Licensed Extension') { UI.openURL( PUBLIC_LICENSE ) }
	end

 end
