#! /usr/bin/env ruby

# demo irc bot
# Author: Alice "Duchess" Archer
# Description:
# Demo IRC Bot built using my rirc framework

load 'rirc.rb'

# setup
network = "irc.freenode.net"
port = 6667
nick = "rubybot"
username = "rubybot"
realname = "rubybot"
channels = ["#YOURCHANNEL"]
admins = ["YOURNICK"]
backlog = []
plugins_list = ["cat.rb"]

# create the bot
puts "creating bot"
bot = IRCBot.new(network, port, nick, username, realname)

# create the plugin manager and tell it where to look for plugins
puts "creating plugin manager"
plug = Plugin_manager.new("./plugins")

# initial connect
bot.connect
puts "Connecting"
puts "	↪ network = #{bot.network}"
puts "	↪ port = #{bot.port}"


# send connect info
bot.auth
puts "Auth"
puts "	↪ nick = #{bot.nick_name}"

# joining channels
channels.each { |a| bot.join(a) }

# setting admins
admins.each { |a| bot.add_admin(a) }

# loading plugins
puts "Loading plugins"
plugins_list.each do |a|
	print "loading #{a}..."
	STDOUT.flush
	puts plug.plugin_load(a)
end

puts "Done"

# main loop
until bot.socket.eof? do
	msg = bot.read

	if msg == "PING" # PING and PONG are handled by the reading of the socket
		next
	else
		msg = bot.parse(msg)
		backlog.push(msg)

		if msg.message_regex(/^hello/) then bot.privmsg(msg.channel, "hello #{msg.nick}"); next; end

		if msg.message_regex(/^`info$/)
			bot.privmsg(msg.nick, "this is a demo irc bot built using the rirc framework")
			bot.privmsg(msg.nick, "the rirc framework is an irc bot framework built in ruby")
			bot.privmsg(msg.nick, "the rirc framework is developed by Alice Archer")
			bot.privmsg(msg.nick, "the rirc framework is published under the MIT license")
			bot.privmsg(msg.nick, "the rirc framework is available here: https://github.com/The-Duchess/ruby-irc-framework")
		end

		if msg.message_regex(/^`part /)
			tokens = msg.message.split(" ")
			reason = ""
			1.upto(tokens.length - 1) { |a| reason.concat("#{a} ") }
			reason = reason[0..-2].to_s
			bot.part(msg.channel, reason)

			next
		end

		if msg.message_regex(/^`quit /)
			tokens = msg.message.split(" ")
			reason = ""
			1.upto(tokens.length - 1) { |a| reason.concat("#{a} ") }
			reason = reason[0..-2].to_s
			bot.quit(reason)

			next
		end

		if msg.message_regex(/^`help /)
			tokens = msg.message.split(" ")
			help = plug.plugin_help(tokens[1])
			if help != nil
				bot.privmsg(msg.channel, "#{msg.nick}: #{help}")
			else
				bot.privmsg(msg.channel, "#{msg.nick}: plugin #{tokens[1]} not found")
			end
		end

		if msg.message_regex(/^`load /)
			tokens = msg.message.split(" ")
			response = plug.plugin_load(tokens[1])
			bot.privmsg(msg.channel, "#{response}")
		end

		if msg.message_regex(/^`unload /)
			tokens = msg.message.split(" ")
			plug.unload(tokens[1])
			bot.privmsg(msg.channel, "#{tokens[1]} unloaded")
		end

		if msg.message_regex(/^`reload /)
			tokens = msg.message.split(" ")
			plug.reload(tokens[1])
			bot.privmsg(msg.channel, "#{tokens[1]} reloaded")
		end

		if msg.message_regex(/^`list$/)
			names = []
			plug.plugins.each { |a| names.push(a.name) }
			names.each { |a| bot.privmsg(msg.channel, a)}
		end

		responses = plug.check_all(msg, admins, backlog)

		responses.each do |a|
			if a != ""
				bot.say(a)
			end
		end
	end
end
