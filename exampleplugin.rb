#!/bin/env ruby
#############################################################################################
# author: apels <Alice Duchess>
#############################################################################################

require 'rirc.rb'

class Template < Pluginf
	#any functions you may need

	#your definition for script
	def script(message, admins, backlog)

		return "string"
	end
end

# allows you to support multiple regexes
# prefix = [
#		//,
#		//
#	   ]
#
# reg_p = Regexp.union(prefix)

reg_p = // # regex to call the plugin
fn = "file name" # file name
na = "template" # name for plugin
de = "NOTES ^| HELP" # description and or help

#plugin = Class_name.new(regex, name, file_name, help)
$temp_plugin = Template.new(reg_p, na, fn, de)
