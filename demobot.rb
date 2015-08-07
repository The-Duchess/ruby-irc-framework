#! /usr/bin/env ruby

require_relative 'rirc.rb' # this line must be at the top of the file

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
# [optional] if you are going to use plugins
plugin_folder = "./plugins"
plugins_list = ["cat.rb", "youtube.rb"]

# Create the IRCBot object, or your irc client
bot = IRCBot.new(network, port, nick, username, realname)
# Add admins to the IRCBOT object, or your irc client
bot.set_admins(admins)

plug = Plugin_manager.new(plugin_folder)
plugins_list.each { |a| plug.plugin_load(a) }

commands = Commands_manager.new

commands.on /^!join (\S+)/ do |ircbot, msg, pluginmgr|
      channel = msg.message.split(" ")[1].to_s
      ircbot.join(channel)
end

bot.on :message do |msg|
      
      commands.check_cmds(bot, msg, plug)

      responses = plug.check_all(msg, bot.admins, bot.backlog)
      responses.each { |a| bot.say(a) }
end

# Add event hooks for custom code to be run
# Check the README for more help
bot.on :message do |msg|
      case msg.message
      when /^#{bot.nick_name}[,:] (h|H)ello/ then
            bot.privmsg(msg.channel, "hi: #{msg.nick}")
      end
end

# Hand the bot connection info and have the bot do the initial connect
# it will connect, identify if the nickserv_pass is not "", and join all
# members of the channels array.
# you can prevent automatically joining by having that done later
# a) triggered by commands
# and
# b) have channels be empty.
# should you not require a password then you can set
# a) use_pass to false
# and
# b) set pass to "" or anything
bot.setup(use_ssl, use_pass, pass, nickserv_pass, channels)

# Tell the bot to start running
bot.start!
