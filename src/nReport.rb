# SketchUp Extension: Export Reports
# Version: 1.0.0
# License: GNU
# URL: https://github.com/INTITY/nReport

require 'sketchup.rb'
require 'extensions.rb'

module Sketchup
	module Extensions
		module NReport

			# Extension Info
			PLUGIN_ID       = 'nReport'.freeze
			PLUGIN_NAME     = 'nReport'.freeze
			PLUGIN_VERSION  = '1.0.0'.freeze

			# Resource paths
			FILENAMESPACE = File.basename(__FILE__, '.*')
			PATH_ROOT     = File.dirname(__FILE__).freeze
			PATH          = File.join(PATH_ROOT, FILENAMESPACE).freeze
			PATH_ICONS    = File.join(PATH, 'icons').freeze

			# Extension loader
			unless file_loaded?(__FILE__)
			  loader = File.join( PATH, 'loader.rb' )
			  ex = SketchupExtension.new(PLUGIN_NAME, loader)
			  ex.description = 'Export Reports extension.'
			  ex.version     = PLUGIN_VERSION
			  ex.copyright   = 'INTTTY 2015'
			  ex.creator     = 'INTITY'
			  Sketchup.register_extension(ex, true)
			end
		end
	end
end