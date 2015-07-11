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
puts "	↪ network = irc.cat.pdx.edu"
puts "	↪ port = 6667"


# send connect info
bot.auth
puts "Auth"
puts "	↪ nick = apelsbot"

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

		if msg.message.match(/^hello/) then bot.privmsg(msg.channel, "hello #{msg.nick}"); next; end

		if msg.message.match(/^`part /)
			tokens = msg.message.split(" ")
			reason = ""
			1.upto(tokens.length - 1) { |a| reason.concat("#{a} ") }
			reason = reason[0..-2].to_s
			bot.part(msg.channel, reason)

			next
		end

		if msg.message.match(/^`quit /)
			tokens = msg.message.split(" ")
			reason = ""
			1.upto(tokens.length - 1) { |a| reason.concat("#{a} ") }
			reason = reason[0..-2].to_s
			bot.quit(reason)

			next
		end

		responses = plug.check_all(msg, admins, backlog)

		responses.each do |a|
			if a != ""
				bot.say(a)
			end
		end
	end
end
