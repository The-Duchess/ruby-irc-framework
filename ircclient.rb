#! /usr/bin/env ruby

require_relative 'rirc.rb' # this line must be at the top of the file

network = "irc.freenode.net"
port = 6667
pass = ""
nick = "YOURNICK"
username = "rircbot"
realname = "rircbot"
nickserv_pass = ""
channels = ["#YOURCHANNEL"]
use_ssl = false
use_pass = false

bot = IRCBot.new(network, port, nick, username, realname)
bot.set_admins(admins)

bot.on :message do |msg|
      puts "[#{msg.channel}] <#{msg.nick}>: #{msg.message}"
end

bot.setup(use_ssl, use_pass, pass, nickserv_pass, channels)
bot_thread = Thread.new { bot.start! }

main_thread = Thread.new {

      while true
            input = STDIN.gets
            channel = input.split(" ")[0].to_s
            output = ""
            1.upto(input.split(" ").length - 1) do |i|
                  output.concat("#{input.split(" ")[i]} ")
            end
            output = output[0..-2].to_s
            bot.privmsg(channel, output)
      end

}

while true
      sleep 0.001
      bot_thread.join(0.1)
      sleep 0.001
      main_thread.join(0.1)
end
