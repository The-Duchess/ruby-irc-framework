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
	def initialize(command, nick, channel, message, ircmsg)
		@command = command
		@nick = nick
		@channel = channel
		@message = message
		@ircmsg = ircmsg
	end

	def ircmsg
		return @ircmsg
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

	def check_regex(type, regex)

		if type == "command"
			if @command.match(regex) then return true end
		elsif type == "nick"
			if @nick.match(regex) then return true end
		elsif type == "channel"
			if @channel.match(regex) then return true end
		elsif type == "message"
			if @message.match(regex) then return true end
		else
			if @message.match(regex) then return true end
		end

		return false
	end

	def message_regex(regex)
		if @message.match(regex) then return true end

		return false
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

class Plugin_manager
	def initialize(plugin_folder)
		@plugins = []
		@plugin_folder = plugin_folder
	end

	# returns all the plugins
	def plugins

		if @plugins.length == 0
			return []
		end

		return @plugins
	end

	# search functions
	def get_names

		if @plugins.length == 0
			return []
		end

		names = []

		@plugins.each { |a| names.push(a.name) }

		return names
	end

	def get_helps

		if @plugins.length == 0
			return []
		end

		names = []

		@plugins.each { |a| names.push(a.help) }

		return names
	end

	def get_files

		if @plugins.length == 0
			return []
		end

		names = []

		@plugins.each { |a| names.push(a.file_name) }

		return names
	end

	def get_chans

		if @plugins.length == 0
			return []
		end

		names = []

		@plugins.each { |a| names.push(a.chans) }

		return names
	end

	def get_regexps

		if @plugins.length == 0
			return []
		end

		names = []

		@plugins.each { |a| names.push(a.regex) }

		return names
	end

	def get_plugin(name) # gets a plugin by name or nil if it is not loaded

		if @plugins.length == 0
			return nil
		end

		@plugins.each { |a| if a.name == name then return a end }

		return nil
	end

	def plugin_help(name) # gets the help for a plugin

		if @plugins.length == 0
			return nil
		end

		@plugins.each { |a| if a.name == name then return a.help end }

		return nil
	end

	def plugin_file_name(name) # gets the file name for a plugin

		if @plugins.length == 0
			return nil
		end

		@plugins.each { |a| if a.name == name then return a.file_name end }

		return nil
	end

	def plugin_chans(name) # gets the array of channels for a plugin

		if @plugins.length == 0
			return nil
		end

		@plugins.each { |a| if a.name == name then return a.chans end }

		return nil
	end

	def plugin_regex(name) # gets the regex for a plugin

		if @plugins.length == 0
			return nil
		end

		@plugins.each { |a| if a.name == name then return a.regex end }

		return nil
	end

	# check if a plugin is loaded
	def plugin_loaded(name)

		if @plugins.length == 0
			return false
		end

		@plugins.each do |a|
			if a.name == name
				return true
			end
		end

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

 		if @plugins.length == 0
			return ""
		end

		if !plugin_loaded(name)
			return ""
		else
			if message.message.match(get_plugin(name).regex) and (get_plugin(name).chans.include? "any" or get_plugin(name).chans.include? message.channel)
				begin
					return get_plugin(name).script(message, admins, backlog) # plugins use the IRC_message object
				rescue => e
					return "an error occured for plugin: #{name}"
				end
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

		if @plugins.length == 0
			return []
		end

		response = []

		# this is incredibly inneficient but it makes check_plugin flexible
		@plugins.each { |a| response.push(check_plugin(a.name, message, admins, backlog)) }

		return response
	end

	# load
	def plugin_load(name)

		$LOAD_PATH << "#{@plugin_folder}"
		response = ""
		temp_plugin = nil
		if name.match(/.rb$/)
			begin
				load "#{name}"
				temp_plugin = Loadable_Plugin::temp
				if plugin_loaded(temp_plugin.name)
					temp_plugin = nil
					return "Plugin #{name} is already loaded"
				end
				@plugins.push(temp_plugin)
				temp_plugin = nil
				response = "#{name[0..-4]} loaded"
			rescue => e
				response = "cannot load plugin"
			end
		else
			begin
				load "#{name}.rb"
				temp_plugin = Loadable_Plugin::temp
				if plugin_loaded(temp_plugin.name)
					temp_plugin = nil
					return "Plugin #{name} is already loaded"
				end
				@plugins.push(temp_plugin)
				temp_plugin = nil
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

		return "plugin #{name} unloaded"
	end

	# reload
	def reload(name)

		if !plugin_loaded(name)
			return "plugin is not loaded"
		end

		temp_file_name = get_plugin(name).file_name

		unload(name)
		plugin_load(temp_file_name)

		return "plugin #{name} reloaded"
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
		@ignore = []
		@hooks = {}
		@backlog = []
	end

	def backlog
		return @backlog
	end

	def ignore
		return @ignore
	end

	def channels
		return @channels
	end

	def admins
		return @admins
	end

	def network

		return @network
	end

	def port

		return @port
	end

	def nick_name

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
		if !@channels.include? channel then @channels.push(channel) end
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

		@nick = nick
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

	def identify(nickserv_pass)
		say "PRIVMSG nickserv :identify #{nickserv_pass}"
	end

	def auth(nickserv_pass)
		say "VERSION"
		say "USER #{@user_name} * * :#{@real_name}"
		nick(@nick)
		if nickserv_pass != "" and nickserv_pass != nil
			identify(nickserv_pass)
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
		nick_n = message_reg[:prefix].to_s.split("!")[0]
		command = message_reg[:command].to_s
		chan = message_reg[:params].to_s
		message = message_reg[:trail].to_s

		message = message.chomp

		if chan == @nick then chan = nick_n end

		ircmsg = IRC_message.new(command, nick_n, chan, message, msg)

		return ircmsg
	end

	def add_admin(nick)
		@admins.push(nick)
	end

	def remove_admin(nick)
		@admins.delete_if { |a| a == nick }
	end

	def add_ignore(nick)
		@ignore.push(nick)
	end

	def remove_ignore(nick)
		@ignore.delete_if { |a| a == nick }
	end

	def on(type, &block)
		type = type.to_s
		@hooks[type] ||= []
		@hooks[type] << block
	end

	def set_admins(admins_s)
	      admins_s.each { |a| self.add_admin(a) }
	end

	def join_channels(channels_s)
		channels_s.each { |a| self.join(a) }
	end

	def create_log
		if !File.exist?("./log")
			File.open("./log", "w+") { |fw| fw.write("Command and Privmsg LOGS") }
		end
	end

	def setup(use_ssl, use_pass, pass, nickserv_pass, channels_s)
		self.connect
		if use_ssl then self.connect_ssl end
		if use_pass then self.connect_pass(pass) end
		self.auth(nickserv_pass)

		self.create_log

		self.join_channels(channels_s)

		self.on :message do |msg|

			if msg.channel == msg.nick
				File.write("./log", msg.ircmsg, File.size("./log"), mode: 'a')
			end

			if !self.nick_name == msg.nick and !self.ignore.include? msg.nick
				@backlog.push(msg)
			end
		end

		self.on :message do |msg|
			if self.admins.include? msg.nick and msg.message_regex(/^`plsgo$/) then abort end
		end
	end

	def start!

	      until self.socket.eof? do
	      	ircmsg = self.read
			msg = self.parse(ircmsg)

			if ircmsg == "PING" or self.ignore.include?(msg.nick) then next end

			begin
				hooks = @hooks['message']
				if hooks != nil
					hooks.each { |h| h.call(msg) }
				end
			rescue => e
				# do not do anything
			end

			begin
				hooks = @hooks['command']
				if hooks != nil
					hooks.each { |h| h.call(msg.channel, msg.command) }
				end
			rescue => e
				# do not do anything
			end

			begin
				hooks = @hooks['ircmsg']
				if hooks != nil
					hooks.each { |h| h.call(msg.nick, msg.command, msg.channel, msg.message) }
				end
			rescue => e
				# do not do anything
			end
	      end
	end
end
