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

bot = IRCBot.new(network, port, nick, username, realname)
plug = Plugin_manager.new("./plugins")
plugins_list.each { |a| plug.plugin_load(a) }
bot.set_admins(admins)
bot.setup(use_ssl, use_pass, pass, nickserv_pass, channels)

bot.on :message do |msg|
      case msg.message
      when /^#{bot.nick_name}[,:] (h|H)ello/ then
            bot.privmsg(msg.channel, "hi: #{msg.nick}")
      end
end

bot.on :message do |msg|
      plug.plugins.each do |plugin|
            if msg.message_regex(plugin.regex) then bot.say(plugin.script(msg, bot.backlog, bot.admins)) end
      end
end

# because of the ability to add hooks you can add a hook to add hooks from commands given during run time
#bot.on :message do |msg|
#   if bot.admins.include? msg.nick and msg.message_regex(/`add cmd (\S+ )*/)
#     param = msg.message.split(" ")[2..-1]
#
#     bot.on :message do |msg_t|
#           # add command
#          @command = param[0]
#           if msg_t.message_regex(Regexp.new(@command)
#                 # command based on param
#           end
#           
#     end
#   end
#end

bot.start!
