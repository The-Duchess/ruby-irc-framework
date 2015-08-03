#!/bin/env ruby
#############################################################################################
# author: apels <Alice Duchess>
#############################################################################################

load 'rirc.rb'

class Cat_print < Pluginf

	# any functions you may need can be included here

	# your definition for function called if the regex for the plugin matches the message.message
	# inputs:
	# 	- IRC_message object
	# 	- admins array
	# 	- backlog array of IRC_message objects
	# output: string to send to the socket
	def script(message, admins, backlog)

		# plugins must return the raw mesaage they wish to have sent to the socket
		# return "PRIVMSG #{message.chan} :hello"
		# or you can use functions to simplify this
		# some are provided below
		return privmsg(message.channel, "~( ^^)")
	end

	def privmsg(dest, message)
		return "PRIVMSG #{dest} :#{message}"
	end

	def action(dest, message)
		return "PRIVMSG #{dest} :\01ACTION\07\01 #{message}"
	end

	def notice(dest, message)
		return "NOTICE #{dest} :#{message}"
	end
end

# allows you to support multiple regexes
# prefix = [
#		//,
#		//
#	   ]
#
# reg_p = Regexp.union(prefix)

reg = /^`cat/ # regex to call the plugin
filename = "cat.rb" # file name
pluginname = "cat" # name for plugin
description = "`cat will print a cat" # description and or help

# plugin = Class_name.new(regex, name, file_name, help)

module Loadable_Plugin
	temp = Cat_print.new(reg, pluginname, filename, description)
end
