#! /bin/env ruby
#
############################################################
# Author: Alice "Duchess" Archer
# Name: rirc
# Description: IRC framework for IRC bots written in ruby
############################################################

require 'socket'
require 'openssl'

class IRC_message
	def initialize(command, nick, channel, message)
		@command = command
		@nick = nick
		@channel = channel
		@message = message
	end

	def message
		return @message
	end

	def nick
		return @nick
	end

	def command
		return @command
	end

	def channel
		return @channel
	end
end

class Pluginf

	def initialize(regex, name, file_name, help)
		@regexp = Regexp.new(regex.to_s)
		@name = name.to_s
		@file_name = file_name.to_s
		@help = help
		@chan_list = []
		@chan_list.push("any")
	end

	# default function
	def script(message, nick, chan)
		
	end

	def regex
		return @regexp
	end

	def chans
		return @chan_list
	end

	def name
		return @name
	end

	def file_name
		return @file_name
	end

	def help
		return @help
	end

	def cleanup
		return ""
	end
end

class plugin_manager
	def initialize(plugin_folder)
		@plugins = []
		@plugin_folder = plugin_folder
	end

	# returns all the plugins
	def plugins

		return @plugins
	end

	# search functions
	def get_plugin(name) # gets a plugin by name or nil if it is not loaded
		@plugins.each { |a| if a.name == name then return a end }

		return nil
	end

	def plugin_help(name) # gets the help for a plugin
		@plugins.each { |a| if a.name == name then return a.help end }

		return nil
	end

	def plugin_file_name(name) # gets the file name for a plugin
		@plugins.each { |a| if a.name == name then return a.file_name end }

		return nil
	end

	def plugin_chans(name) # gets the array of channels for a plugin
		@plugins.each { |a| if a.name == name then return a.chans end }

		return nil
	end

	def plugin_regex(name) # gets the regex for a plugin
		@plugins.each { |a| if a.name == name then return a.regex end }

		return nil
	end

	# check if a plugin is loaded
	def plugin_loaded(name)
		@plugins.each { |a| if a.name == name then return true end }

		return false
	end

	# regex check function
	# this function uses the IRC_message object for message input
	# inputs:
	# 	- name
	# 	- IRC_message object
	# 	- array of admins [can be an empty array]
	# 	- backlog array [can be an empty array]
	# output: string
 	def check_plugin(name, message, admins, backlog) #checks an individual plugin's (by name) regex against message
		if !plugin_loaded(name)
			return ""
		else
			if message.message.match(get_plugin(name).regex)
				return get_plugin(name).script(message, admins, backlog) # plugins use the IRC_message object
			end
		end

		return ""
	end

	# regex check function that returns responses for all plugins in an array
	# inputs:
	# 	- IRC_message object
	# 	- array of admins [can be an empty array]
	# 	- backlog array [can be an empty array]
	# output: array of strings
	def check_all(message, admins, backlog)
		response = []
		@plugins.each { |a| response.push(check_plugin(a.name, message, admins, backlog)) }

		return response
	end

	# load
	# to do: solve the issue of the old plugins using a global array
	def load(name)

		if plugin_loaded(name)
			return "plugin is already loaded"
		end

		$LOAD_PATH << "#{@plugin_folder}"
		response = ""
		$temp_plugin = nil # allows a global to be set, thus allowing the plugin to create a temporary we can add
		if name.match(/.rb$/)
			begin
				load "#{name}"
				@plugins.push($temp_plugin)
				$temp_plugin = nil
				response = "#{name[0..-4]} loaded"
			rescue => e
				response = "cannot load plugin"
			end
		else
			begin
				load "#{name}.rb"
				@plugins.push($temp_plugin)
				$temp_plugin = nil
				response = "#{name} loaded"
			rescue => e
				response = "cannot load plugin"
			end
		end
		$LOAD_PATH << './'
		return response
	end

	# unload
	def unload(name)

		if !plugin_loaded(name)
			return "plugin is not loaded"
		end

		get_plugin(name).cleanup
		@plugins.delete_if { |a| a.name == name }
	end

	# reload
	def reload(name)

		if !plugin_loaded(name)
			return "plugin is not loaded"
		end

		temp_name = name
		temp_file_name = get_plugin(name).file_name

		unload(temp_name)
		load(temp_file_name)
	end
end

class IRCBot
	def initialize(network, port, nick, user_name, real_name)
		@network = network
		@port = port
		@nick = nick
		@user_name = user_name
		@real_name = real_name
		@socket = nil
		@channels = []
		@admins = []
	end

	def network

		return @network
	end

	def port

		return @port
	end

	def nick

		return @nick
	end

	def user_name

		return @user_name
	end

	def real_name

		return @real_name
	end

	def socket

		return @socket
	end

	def say(message)

		@socket.puts message
	end

	def join(channel)

		say "JOIN #{channel}"
		@channels.push(channel)
	end

	def connect

		@socket = TCPSocket.open(@network, @port)
	end

	def connect_ssl
		ssl_context = OpenSSL::SSL::SSLContext.new
		ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
		@socket = OpenSSL::SSL::SSLSocket.new(@socket, ssl_context)
		@socket.sync = true
		@socket.connect
	end

	def connect_pass(pass)

		say "PASS #{pass}"
	end

	def nick(nick)

		say "NICK #{nick}"
	end

	def privmsg(dest, message)

		say "PRIVMSG #{dest} :#{message}"
	end

	def action(dest, message)

		privmsg(dest, "\01ACTION #{message}\07\01")
	end

	def notice(dest, message)

		say "NOTICE #{dest} :#{message}"
	end

	def ctcp(dest, message)

		privmsg(dest, "\01VERSION #{message}\07\01")
	end

	def part(dest, message)

		say "PART #{dest} :#{message}"
	end

	def quit(message)

		say "QUIT :#{message}"
	end

	def names(dest)

		say "NAMES #{dest}"
	end

	def auth
		say "VERSION"
		say "USER #{@user_name} * * :#{@real_name}"
		nick(@nick)
		if @nickserv_pass != ""
			say "PRIVMSG nickserv :#{@nickserv_pass}"
		end
	end

	def read
		if !@socket.eof

			msg = @socket.gets

			if msg.match(/^PING :(.*)$/)
				say "PONG #{$~[1]}"
				return "PING"
			end

			return msg
		else
			return nil
		end
	end

	def parse(msg)
		message_reg = msg.match(/^(:(?<prefix>\S+) )?(?<command>\S+)( (?!:)(?<params>.+?))?( :(?<trail>.+))?$/)
		nick = message_reg[:prefix].to_s.split("!")[0]
		command = message_reg[:command].to_s
		chan = message_reg[:params].to_s
		message = message_reg[:trail].to_s

		message = message.chomp

		ircmsg = IRC_message.new(command, nick, chan, message)

		return ircmsg
	end

	def add_admin(nick)

		@admins.push(nick)
	end

	def remove_admin(nick)
		
		@admins.delete_if { |a| a == nick }
	end
end
