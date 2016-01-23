#!/bin/env ruby
#############################################################################################
# author: apels <Alice Duchess>
#############################################################################################

require 'rirc'

# plugin = Class_name.new(regex, name, file_name, help)
module Loadable_Plugin
	class Cat_print < Pluginf


		def script(message, admins, backlog)

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

	def initialize
		@reg = /^`cat/ # regex to call the plugin
		@filename = "cat.rb" # file name
		@pluginname = "cat" # name for plugin
		@description = "`cat will print a cat" # description and or help

		@plugin = Cat_print.new(@reg, @pluginname, @filename, @description)
	end

	def get_plugin
		return @plugin
	end
end

class Loader
	include Loadable_Plugin
end
