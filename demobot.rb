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
plugin_folder = "./plugins"
plugins_list = ["cat.rb", "youtube.rb"]

bot = IRCBot.new(network, port, nick, username, realname)
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

bot.on :message do |msg|
      case msg.message
      when /^#{bot.nick_name}[,:] (h|H)ello/ then
            bot.privmsg(msg.channel, "hi: #{msg.nick}")
      end
end


bot.setup(use_ssl, use_pass, pass, nickserv_pass, channels)
bot.start!
