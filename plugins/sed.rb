#!/bin/env ruby
#############################################################################################
# author: apels <Alice Duchess>
#############################################################################################

# note: example code does not actually run
# a running example should be posted soon

load 'rirc.rb'

module Loadable_Plugin

	class Sed_sr < Pluginf
		def script(message, admins, backlog)


			command_s = message.message

			msg_l = message.message.length.to_i - 1
			temp_sa = ""
			temp_sb = ""

			i = 0
			2.upto(msg_l) do |a|
				if message.message[a] == "/" and message.message[a - 1] != "\\"
					break
				else
					temp_sa.concat(message.message[a])
					i = i + 1
				end
			end

			i = i - 1

			i.upto(msg_l) do |b|
				if message.message[b] == "/" and message.message[b] != "\\"
					break
				else
					temp_sb.concat(message.message[b])

				end
			end

			begin
				sed_a = Regexp.new(temp_sa.to_s)
			rescue => e
				return ""
			end

			sed_b = temp_sb.to_s

			included = false
			string_a = ""
			nick_a = ""
			@r = ""
			@m = ""

			(backlog.length - 2).downto(0) do |i|
				if backlog[i].message_regex(/^ACTION /)
					@r = "» #{backlog[i].nick} "
					tokens = backlog[i].message.split(" ")
					1.upto(tokens.length - 1) { |a| @m.concat("#{tokens[a].to_s} ") }
					@m = @m[0..-2].to_s
				else
					@r = "「#{backlog[i].nick}」 "
					@m = backlog[i].message
				end

				if @m.match(sed_a) and backlog[i].channel == message.channel then
					included = true
					string_a = @m
					nick_a = backlog[i].nick
					break
				else
					next
				end
			end

			if included then
				File.open("./temp", 'w') { |fw| fw.puts "#{string_a}" }
				File.open("./temp_s", 'w') { |fw| fw.puts "#{command_s}" }
				@r_s = `sed -r -f ./temp_s < ./temp`
				if @r_s.length > 0 then
					@r.concat(@r_s.to_s)
				else
					@r = ""
				end
			else
				@r = ""
			end

			if @r != "" then
				return privmsg(message.channel, @r)
			else
				return ""
			end
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

		@reg = /(^s\/(.*)\/(.*)\/(\w)?)/ # regex to call the plugin
		@filename = "sed.rb" # file name
		@pluginname = "sed" # name for plugin
		@description = "provides sed style search replace with backreferences" # description and or help
		# @chan_list = ["#chat"] # channels this plugin is allowed to react from

		# plugin = Class_name.new(regex, name, file_name, help)
		@plugin = Sed_sr.new(@reg, @pluginname, @filename, @description)
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
