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
	
	def check_regex(type, regex)
		if type == "command"
			return true if @command.match(regex) end
		elsif type == "nick"
			return true if @nick.match(regex) end
		elsif type == "channel"
			return true if @channel.match(regex) end
		elsif type == "message"
			return true if @message.match(regex) end
		else # default to message
			return true if @message.match(regex) end	
		end
		
		return false
	end
	
	def message_regex(regex)
		return true if @message.match(regex) end
		
		return false
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
