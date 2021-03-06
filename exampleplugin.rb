#!/bin/env ruby
#############################################################################################
# author: apels <Alice Duchess>
#############################################################################################

# note: example code does not actually run
# a running example should be posted soon

require 'rirc'

module Loadable_Plugin
	class Template < Pluginf

		# any functions you may need can be included here

		# your definition for function called if the regex for the plugin matches the message.message
		# inputs:
		# 	- IRC_message object
		# 	- admins array
		# 	- backlog array of IRC_message objects
		# output: string to send to the socket
		# NOTE:
		# DO NOT CHANGE THE NAME OR ARGUMENTS TO THIS FUNCTION
		# YOUR PLUGIN WILL NOT WORK
		def script(message, admins, backlog)

			# plugins must return the raw message they wish to have sent to the socket
			# return "PRIVMSG #{message.chan} :hello"
			# or you can use functions to simplify this
			# some are provided below
			return privmsg(message.channel, "hello")
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

	def initialize
		# information the plugin needs to be initialized with

		# allows you to support multiple regexes
		# prefix = [
		#		//,
		#		//
		#	   ]
		#
		# reg_p = Regexp.union(prefix)

		@reg = // # regex to call the plugin
		@filename = "exampleplugin.rb" # file name
		@pluginname = "template" # name for plugin
		@description = "NOTES ^| HELP" # description and or help
		# @chan_list = ["#chat"] # channels this plugin is allowed to react from

		# plugin = Class_name.new(regex, name, file_name, help)
		# this temporary global is used for handing the new plugin back to the bot
		@plugin = Template.new(@reg, @pluginname, @filename, @description)
		# @plugin = Template.new(@reg, @pluginname, @filename, @description, @chan_list)
	end

	# DO NOT CHANGE
	def get_plugin
		return @plugin
	end
end

# DO NOT CHANGE
# redefine the loader for the plugin we wish to load
class Loader
	include Loadable_Plugin
end
