#----------------------------------------------------------------------------#
## Copyright 2012, Trimble Navigation Limited

# This software is provided as an example of using the Ruby interface
# to SketchUp.

# Permission to use, copy, modify, and distribute this software for 
# any purpose and without fee is hereby granted, provided that the above
# copyright notice appear in all copies.

# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#----------------------------------------------------------------------------#

require 'sketchup.rb'

module Sketchup::Extensions::NReport

  # AttributeReporter class, provide useful reporting for the attributes attached to your
  # Components and Groups
  #
  # Put this file in the Plugins directory and you should be good to go.
  # You will have a right click to save attributes information for a selection and 
  # a menu under Plugins to save the whole Model attributes information.  
  class AttrReporter
        
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
          @cell_mid   = ";"
          @cell_end   = ";"
  
        when 'html'
        
          @doc_start =  "<html>" +
                        "<head>" +
                          "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">" +
                        "</head>" +
                        "<style>" +
                        "table {" +
                        "  padding: 0px;" +
                        "  margin: 0px;" +
                        "  empty-cells: show;" +
                        "  border-right: 1px solid silver;" +
                        "  border-bottom: 1px solid silver;" +
                        "  border-collapse: collapse;" +
                        "}" +
                        "td {" +
                        "  padding: 4px;" +
                        "  margin: 0px;" +
                        "  border-left: 1px solid silver;" +
                        "  border-top: 1px solid silver;" +
                        "  font-family: sans-serif;" +
                        "  font-size: 9pt;" +
                        "  vertical-align: top;" +
                        "}" +
                        "</style>" +
                        "<table border=1>"
          @doc_end    = "</table>" +
                        "</html>"
          @row_start  = "   <tr>"
          @row_end    = "   </tr>"
          @cell_start = "    <td>"
          @cell_mid   = "</td>" +
                        "<td>"
          @cell_end   = "</td>"
          
        else 'xml'
          
          @doc_start = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
                       "<xs:schema xmlns:xs=\"http://www.w3.org/2001/XMLSchema\" targetNamespace=\"http://tempuri.org/po.xsd\" xmlns=\"http://tempuri.org/po.xsd\" elementFormDefault=\"qualified\">" +
                        "<table>"
          @doc_end    = "</table>" +
                        "</xs:schema>"
          @row_start  = "   <tr>"
          @row_end    = "   </tr>"
          @cell_start = "     <td>"
          @cell_mid   = "     </td>" +
                        "<td>"
          @cell_end   = "</td>"
      end    
    end #set_up
        
    #these are some functions useful for formatting the generated output 
    # Processes anything into a float.
    #  Args:
    #     value  The value to convert.
    # Returns:
    #     The value as a float.
    def to_number(value)
      # If we're passed a string, strip off any characters that are not digits,
      # periods, or minus signs.
      if value.kind_of? String
        # If the first character is anything but a digit, period, or a minus sign,
        # then this string is not convertable, so return 0.0. Otherwise, a 
        # string like "myPart!x/1000+75*99280" would parse down to 10007599280.
        if value =~ /^[^\d\.\-]/
          return 0.0
        end
        value = value.gsub(/[^\d\.\-]/, '')
      end
      
      value = value.to_f
      if value.to_s == "NaN"
        return 0.0
      else
        return value
      end
    end
   
   
    # Cleans up strings for inclusion inside XML structure. Replaces problematic
    # characters with their XML escaped version.
    #
    #   Args:
    #      value: a string that we want escaped
    #
    #   Returns:
    #      string: an xml-friendly version suitable for parsing
    def clean_for_xml(value)
      value = value.to_s
      value = value.gsub(/\</,'<')
      value = value.gsub(/\>/,'>')
      value = value.gsub(/\"/,'"')
      value = value.gsub(/\'/,"'")
      return value
    end
  
    # Clean up any point rounding weirdness for purposes of display andfilename.split('.').last
    # comparison.
    #
    #  Args:
    #     value  The value to convert.
    # Returns:
    #     The value as a string, containing number truncated to 6 decimal places,
    #     and stripped of trailing zeroes.
    def clean_number(value)
      if is_number(value)
        value = (((value.to_f*1000000.0).round) / 1000000.0).to_s
        value = value.gsub(/\.0$/, '')
      end
      return value
    end
  
    # Tells us whether a passed value contains a parsable number.
    #  Args:
    #     value  The value to check.
    # Returns:
    #     true if the value as a string contains nothing but digits and decimals
    #       and the negative sign.
    def is_number(value)
      return value.to_s =~ /^\-*\d+\.*\d*$/
    end
  
  
    # This method returns a named attribute from the DC dictionary. It looks
    # on the instance first... if no attribute is found there, it looks on
    # the definition next.
    #
    #   Args:
    #      entity: reference to the entity to get the value from
    #      name: string name of the attribute to return the value for
    #
    #   Returns:
    #      the value of the attribute, or nil if it can't determine that
    def get_attribute_value(entity, name)
      name = name.downcase
  
      if (entity.typename == 'ComponentInstance')
        value = entity.get_attribute(@dictionary_name, name)
        if (value == nil)
          value = entity.definition.get_attribute(@dictionary_name, name)
        end
        return value
      elsif (entity.typename == 'Group' || entity.typename == "Model" || entity.typename == 'ComponentDefinition')
        return entity.get_attribute(@dictionary_name, name)
      else
        return nil
      end
    end
    
    # This methods loops through all the model entities and process them in case they are
    # either Components or Groups. Here more functionality can be added in case we want
    # to report about different entities.   
    #
    #   Args:
    #      list: beginning entities list used to communicate to this function 
    #      whether or not we are processing all the model entities or just the current 
    #      selection 
    #
    #   Returns:
    #      None
    def collect_attributes(list)
      n = 0
      # While there are still entities in the list array,  
      # determine their type and count them.
      while list != []    
        list.each do |item| 
        n +=1
        type = item.typename
        case type
          when 'Group'
            # Add all the entities that are in that group into the group_list array.
            item.entities.each do |entity|  
              @group_list.push entity
            end
            #get the attributes and put them in the report string
            create_report_string(item, n)
            @group_list.delete(item)
          
          when 'ComponentInstance'
            # You can call .entities on Component Definition, but not on 
            # Component Instance. You need to figure out which 
            # ComponentDefinition the instance belongs to.
            #(ComponentDefinition=ComponentInstance.definition)
            item.definition.entities.each do |entity|
              # Add all the entities in the component to the component_list.
              @component_list.push entity  
            end
            #get the attributes and put them in the report string
            create_report_string(item, n)
            #get rid of the item we have already examined in the list
            @component_list.delete(item)
        end
      end
      # Update the list array so it countains only the entities 
      # that were part of sub-groups and sub-arrays. Those 
      # sub-entities haven't been counted yet.
      list = @group_list + @component_list
      # Clear out the group and component lists so they're 
      # ready for the next level of sub-groups/components.
      @group_list.clear
      @component_list.clear
      end
    end
  
    # This method returns an ordered array of all attributes that are attached
    # to an entity. In the case of component instances, attributes attached to 
    # both the instance and the definition will be returned.
    #
    #   Args:
    #     attribute_entity: required, reference to the entity to report on
    #
    #   Returns:
    #     array of strings containing attribute names 
    def get_attributes_list(attribute_entity)
      list = {}
      if attribute_entity.attribute_dictionaries
        if attribute_entity.attribute_dictionaries[@dictionary_name]
          dictionary = attribute_entity.attribute_dictionaries[@dictionary_name]
          for key in dictionary.keys
            # Do not show attributes that start with _, as these are internal.
            if key[0..0] != '_'
              list[key] = true
            end
          end
        end
      end
      if attribute_entity.typename == "ComponentInstance"
        attribute_entity = attribute_entity.definition
        if attribute_entity.attribute_dictionaries
          if attribute_entity.attribute_dictionaries[@dictionary_name]
            dictionary = attribute_entity.attribute_dictionaries[@dictionary_name]
            for key in dictionary.keys
              if key[0..0] != '_' # Do not show attributes that start with _, as these are internal.
                list[key] = true
              end
            end
          end
        end
      end
      return list.keys
    end
  
    # This method populate the @report_data array with all the attributes attached
    # to an entity. In the case of component instances, attributes attached to 
    # both the instance and the definition will be returned.
    #
    #   Args:
    #     entity: Reference to the entity to report on
    #     number: Used to keep track of the times we have looped through the 
    #     model/selection entities. This can be modified to be used to keep 
    #     track of the depth of the reported on entities.  
    #
    #   Returns:
    #     a report string containing the collected attributes data 
    def create_report_string(entity, number)
      cell_data = []
        if entity.typename == "Model" || entity.typename == "Group" ||
          entity.typename == "ComponentInstance"
          # Add to list of attributes if we find some that aren't on the list.
          for attribute_name in get_attributes_list(entity)
            if @report_attribute_list.include?(attribute_name) == false
              if attribute_name[0..0] != '_'
                @title_array.push(attribute_name.upcase)
                @report_attribute_list.push attribute_name
              end
            end
          end
          
          # Try to get a nice, human-readable name for the entity.
          entity_name = entity.name
          if entity_name.length < 1
            if entity.typename == 'ComponentInstance'
              entity_name = entity.definition.name
            elsif entity.typename == 'Model'
              entity_name = 'Model'
            else
              entity_name = 'Unnamed Part'
            end
          end
  
          # Remember those "hard-coded" columns from the very start of the report?
          # Here is where we manually populate them with explicit ruby calls,
          # since they're not strictly "attributes" that we're wanting to see.
          cell_data.push(number.to_s)
          if entity.typename == "ComponentInstance"
            cell_data.push(entity.definition.name)
          else
            cell_data.push('-')
          end
          cell_data.push(entity.description)
          cell_data.push(entity.layer.name)
  
          # Add the attributes to our report results.
          for attribute_name in @report_attribute_list
            value = get_attribute_value(entity, attribute_name)
            if value.kind_of? Float
              if value.to_s.include?('e-')
                value = 0.0
              else 
                value = clean_number(value)
              end
            end
            if value == nil
              value = ""
            end
            if value == '0.0'
              value = ""
            end
  
            cell_data.push(value)
  
            # Store running totals of each column by forcing every value into a
            # float and storing it. (That means that string attributes will
            # typically have "totals" of 0.0, but that's reasonable from a
            # programmer's perspective.)
            if @totals_by_att_name[attribute_name.upcase] == nil
              @totals_by_att_name[attribute_name.upcase] = 0.0
            end
            @totals_by_att_name[attribute_name.upcase] = 
              @totals_by_att_name[attribute_name.upcase] +
              to_number(value).to_f
            
          end
          # Take our array of attribute values and push it onto our assembled
          # report data.
          @report_data.push(cell_data)  
      end
    end
  
    
    # This method format the @report_data string assembled in create_report_string
    # according to the specified file type in @file_type into the @report_string
    #   Args:
    #     None       
    #   Returns:
    #      None
    def write_report_string
    
        # Create the initial string that is our report.
        @report_string = @doc_start
  
        # Append the "title row" of the report, which is a series of cells that
        # contain the ordered names from @title_array.
        @report_string += @row_start + @cell_start + @title_array.join(@cell_mid) +
          @cell_end + @row_end
  
        # The longest row in the report is guaranteed to be the last row in the
        # report, just because of how we built them. So grab that length now so
        # can can properly append "empty" cells to any records that don't have
        # all of the attributes.
        if @report_data.last.nil?
          UI.messagebox('No Components or Groups in the selection')
          return -1
        else
          longest_row_length = @report_data.last.length
        end
  
        # Let's generate a record for the end of the report that contains the
        # "totals" of any column that appears to be numeric in nature.
        totals_row = []
        for att_name in @title_array
          total = clean_number(@totals_by_att_name[att_name]).to_f
          if total == 0.0
            total = '-'  # This is the string that is put into "empty" cells.
          end
          totals_row.push total
        end
        totals_row[0] = 'TOTALS'
        @report_data.push totals_row
  
        # Now loop across the assembled @report_data and build up our report.
        for cell_data in @report_data
          @report_string += @row_start
          for i in 0..(longest_row_length-1)
            value = cell_data[i]
            @report_string += @cell_start
            if (@filetype == "csv")
              value = value.to_s
              value = value.gsub(/\"/,'""')
              value = '"' + value + '"'
              @report_string += value
            else # default to html output.
              @report_string += clean_for_xml(value)
            end
            @report_string += @cell_end
          end
          @report_string += @row_end
        end
  
        @report_string += @doc_end
  
        # Clean up the report data variables to release memory.
        @report_attribute_list = nil
        @title_array = nil
        @report_data = nil
        @totals_by_att_name = nil
    end
  
  
    def generate_attributes_report(filename, entities_list)
    
      # Start an operation so everything performs faster.
      Sketchup.active_model.start_operation('Generate Report', true)
    
      # initialization of all the class variables used
      set_up(filename)
      
      #collect all the attributes in the selection or in the model
      collect_attributes(entities_list)  
      
      # This check is to capture the case in which the selection for which we were 
      # generating the report did not contain either a Group r a Component 
      if write_report_string == -1
        return
      end
  
      # Open a save dialog on the last known path, (passing nil as the save path 
      # does that automatically.)
      path = UI.savepanel "Save Report", nil, @filename
      if (path and path.split('.').last == @filetype)
        begin
          file = File.new(path, "w")
          file.print @report_string 
        rescue 
          msg = "There was an error saving your report.\n" +
            "Please make sure it is not open in any other software " +
            "and try again."
        ensure
          file.close
        end        
        
      elsif path.nil == false
        UI.messagebox "You Have changed the filetype in the save dialog, please try again."      
      end
  
      # All done, so commit the operation.
      Sketchup.active_model.commit_operation
  
    end
  end
end  