#! /bin/env ruby

require 'rirc.rb'

# setup
network = ""
port = 6697
nick = "rubybot"
username = "rubybot"
realname = "rubybot"
channels = ["#chat"]
admins = ["apels"]
pass = "pass"
nickserv_pass = "pass"
backlog = []

bot = IRCBot.new(network, port, nick, username, realname)

# initial connect
bot.connect

# make ssl connection
bot.connect_ssl

# send pass for network using passwords
bot.connect_pass(pass)

# set nickserv pass
bot.set_nickserv_pass(nickserv_pass)

# send connect info
bot.auth

# joining channels
channels.each { |a| bot.join(a) }

# setting admins
admins.each { |a| bot.add_admin(a) }

# run
until bot.socket.eof? do
	msg = bot.read

	if msg = "PING"
		next
	else
		msg = bot.parse(msg)
		backlog.push(msg)

		if msg.message.match(/^hello/) then bot.privmsg(msg.channel, "hello"); next; end

		if msg.message.match(/^`part /)
			tokens = msg.message.split(" ")
			reason = ""
			1.upto(tokens.length - 1) { |a| reason.concat("#{a} ") }
			reason = reason[0..-2].to_s
			bot.part(msg.channel, reason)
		end

		if msg.message.match(/^`quit /)
			tokens = msg.message.split(" ")
			reason = ""
			1.upto(tokens.length - 1) { |a| reason.concat("#{a} ") }
			reason = reason[0..-2].to_s
			bot.quit(reason)
		end
	end
end
