#! /bin/env ruby
# rirc demobot using hooks

load 'rirc.rb'

network = "irc.freenode.net"
port = 6667
pass = ""
nick = "rircbot"
username = "rircbot"
realname = "rircbot"
nickserv_pass = ""
channels = ["#YOURCHANNEL"]
admins = ["YOURNICK"]
use_ssl = false
use_pass = false
plugins_list = ["cat.rb", "youtube.rb"]
auto_rejoin = true

bot = IRCBot.new(network, port, nick, username, realname)
plug = Plugin_manager.new("./plugins")
plugins_list.each { |a| plug.plugin_load(a) }
bot.set_admins(admins)

# bot.on :message does actions when the irc bot recieves a message
# the argument you have is the IRC_message object
bot.on :message do |msg|
      case msg.message
      when /^#{bot.nick_name}[,:] (h|H)ello/ then
            bot.privmsg(msg.channel, "hi: #{msg.nick}")
      end
end

bot.on :message do |msg|
      responses = plug.check_all(msg, bot.admins, bot.backlog)
      responses.each { |a| bot.say(a) }
end

# bot.on :command allows the bot to respond to commands that may affect it
# the arguments you have are the channel and the command from the IRC_message
bot.on :command do |chnl, cmd|
      case chnl
      when /#{bot.nick_name}$/
            if cmd == 'KICK' and auto_rejoin
                  bot.join(chnl.split(" ")[0].to_s)
            end
      end
end

# bot.on :ircmessage allows the bot to respond to a message but all the parts of the IRC_message
# are given as arguments as opposed to through the IRC_message object for the bot.on :message
bot.on :ircmsg do |nick_t, command_t, channel_t, message_t|
      case message_t
      when /^#{bot.nick_name}[,:] source\?$/ then
            bot.notice(nick_t, "https://github.com/The-Duchess/ruby-irc-framework/blob/master/demobot2.rb")
      end
end

bot.setup(use_ssl, use_pass, pass, nickserv_pass, channels)
bot.start!
