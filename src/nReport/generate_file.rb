



module Sketchup::Extensions::NReport
	
	class GenerateFile
            
		# This method set up the variables that we need to create and the format template.
            # Currently we support CSV and HTML. 
            # More format can be easily defined here by defining the @filetype expected and the
            # various variables @doc_start, @doc_end, @row_start, @row_end, @cell_start, @cell_mid, and @cell_end
            # 
            #   Args:
            #      filename: name of the file to save        
            #   Returns:
            #      None
            #
		def set_up(filename)
      
                  # Arrays
                  @group_list = []
                  @component_list = []
                  
                  # Dictionary where the DC attributes are stored.
                  @dictionary_name = 'dynamic_attributes'
                  
                  # Create some global structures to store our report data in as
                  # it is built. Note that this is a RAM intensive approach, so extremely
                  # large reports could run into memory problems.
                  @report_data = []
                  @totals_by_att_name = {}
                  
                  # This array will contain an ordered list of the attribute names we've
                  # encountered as we walk the model.
                  @report_attribute_list = []
                  
                  # The @title_array will contain an ordered list of all of the "column
                  # titles" to match the @report_attribute_list attributes we've found.
                  @title_array = []
                  
                  # Oh, and there are a few columns that we hard code into the output that
                  # aren't strictly "attributes" from a Ruby API perspective. So pop those
                  # into the column list.
                  @title_array.push('ENTITY')
                  @title_array.push('DEFINITION NAME')
                  @title_array.push('ENTITY DESCRIPTION')
                  @title_array.push('LAYER')
                  
                  # Calculate the file type based on the characters after the last dot in the file name.
                  @filetype = (filename.split('.').last).downcase
                  @filename = filename 
            
                  # In an effort to allow for extending the report formats down the
                  # road, the reporter uses a simple templating system that allows you to
                  # define strings that start and end the report, the rows, and the cells.
                  # you can easily add more formats here 
                  case @filetype
                    
                    when 'csv'
                  
                      @doc_start  = ""
                      @doc_end    = ""
                      @row_start  = ""
                      @row_end    = "\n"
                      @cell_start = ""
                      @cell_mid   = ""
                      @cell_end   = ","
                  
                    else # default to html
                    
                      @doc_start = "<html><head><meta http-equiv=\"Content-Type\" " +
                      "content=\"text/html; charset=utf-8\"></head>\n<style>" +
                      "table {\n" +
                      "  padding: 0px;\n" +
                      "  margin: 0px;\n" +
                      "  empty-cells: show;\n" +
                      "  border-right: 1px solid silver;\n" +
                      "  border-bottom: 1px solid silver;\n" +
                      "  border-collapse: collapse;\n" +
                      "}\n" +
                      "td {\n" +
                      "  padding: 4px;\n" +
                      "  margin: 0px;\n" +
                      "  border-left: 1px solid silver;\n" +
                      "  border-top: 1px solid silver;\n" +
                      "  font-family: sans-serif;\n" +
                      "  font-size: 9pt;\n" +
                      "  vertical-align: top;\n" +
                      "}\n</style>\n" +
                      "<table border=1>"
                      @doc_end    = "</table></html>"
                      @row_start  = "   <tr>\n"
                      @row_end    = "   </tr>\n"
                      @cell_start = "    <td>"
                      @cell_mid   = "</td>\n    <td>"
                      @cell_end   = "</td>\n"
                  end    
            end
	end
end