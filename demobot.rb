#! /usr/bin/env ruby

# demo irc bot
# Author: Alice "Duchess" Archer
# Description:
# Demo IRC Bot built using my rirc framework

load 'rirc.rb'

# setup
network = "irc.cat.pdx.edu"
port = 6667
nick = "apelsbot"
username = "rubybot"
realname = "rubybot"
channels = ["#botdev"]
admins = ["apels"]
backlog = []
#plugins_list = ["exampleplugin.rb"]

bot = IRCBot.new(network, port, nick, username, realname)
#plug = Plugin_Manager.new("./plugins")

# initial connect
bot.connect

# send connect info
bot.auth

# joining channels
channels.each { |a| bot.join(a) }

# setting admins
admins.each { |a| bot.add_admin(a) }

# loading plugins
#plugins_list.each { |a| plug.load(a) }

until bot.socket.eof? do
	msg = bot.read

	if msg == "PING"
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

		#responses = plug.check_all(msg, admins, backlog)

		#response.each do |a|
		#	if a != ""
		#		bot.say(a)
		#	end
		#end
	end
end