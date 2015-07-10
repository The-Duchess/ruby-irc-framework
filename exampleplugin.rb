#!/bin/env ruby
#############################################################################################
# author: apels <Alice Duchess>
#############################################################################################

require 'rirc.rb'

class Template < Pluginf
	#any functions you may need

	#your definition for function called if the regex for the plugin matches the message.message
	# inputs:
	# 	- IRC_message object
	# 	- admins array
	# 	- backlog array of IRC_message objects
	def script(message, admins, backlog)

		# plugins must return the raw mesaage they wish to have sent to the socket
		return "PRIVMSG #{message.chan} :hello"
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
