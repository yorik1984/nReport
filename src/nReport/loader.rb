# SketchUp Extension: Export Reports
# Version: 1.0.0
# License: GNU
# URL: https://github.com/INTITY/nReport

require 'sketchup.rb'
require 'nReport/att_filter.rb'
require 'nReport/att_report.rb'
require 'nReport/attrreporter.rb' #
module Sketchup::Extensions::NReport

	PUBLIC_LICENSE = 'https://github.com/INTITY/nReport/blob/master/LICENSE'
	entities_list = Sketchup.active_model.entities
	att_filter = AttFilter.new
	att_report = AttReport.new
	
	attr_report = AttrReporter.new #
	
	# Check our extension license and add our menu item only if we are licensed.
	ext_id = 'D8E576C8-1A12-432C-87F0-F7435A5A1457'
	ext_lic = Sketchup::Licensing.get_extension_license(ext_id)
	if ext_lic.licensed?
		# Our extension is licensed, add our UI elements
		plugins_menu = UI.menu('Extensions').add_submenu('nReport')
		plugins_menu.add_item('Generate Report as HTML') { 
			attr_report.generate_attributes_report('report.html', entities_list) }
		plugins_menu.add_item('Generate Report as CSV') { 
			attr_report.generate_attributes_report('report.csv', entities_list) }
		plugins_menu.add_item('Generate Report as XML') { 
			attr_report.generate_attributes_report('report.xml', entities_list) }
		plugins_menu.add_separator
		plugins_menu.add_item('Attribute Filter') { att_filter.attributes }
		plugins_menu.add_item('Licensed Extension') { UI.openURL( PUBLIC_LICENSE ) }
		
		# Context Menu Item
		UI.add_context_menu_handler do | context_menu |
			submenu = context_menu.add_submenu('nReport')
			submenu.add_item('Generate Report as HTML') { 
				attr_report.generate_attributes_report("report.html", Sketchup.active_model.selection) }
			submenu.add_item('Generate Report as CSV') { 
				attr_report.generate_attributes_report("report.csv", Sketchup.active_model.selection) }
			submenu.add_item('Generate Report as XML') { 
				attr_report.generate_attributes_report("report.xml", Sketchup.active_model.selection) }
		end
	end
 end
