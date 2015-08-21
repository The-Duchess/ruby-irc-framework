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

commands.on /^!join (\S+)$/ do |ircbot, msg, pluginmgr|
      channel = msg.message.split(" ")[1].to_s
      ircbot.join(channel)
end

commands.on /^!list$/ do |ircbot, msg, pluginmgr|
    ircbot.notice(msg.nick, "Plugins")
    pluginmgr.get_names.each { |a| ircbot.notice(msg.nick, "  - #{a}") }
end

commands.on /^!help (\S+)$/ do |ircbot, msg, pluginmgr|
    name = msg.message.split(" ")[1].to_s
    help = pluginmgr.plugin_help(name)

    if not help == nil
    	ircbot.notice(msg.nick, help)
    else
    	ircbot.notice(msg.nick, "no plugin #{help} found")
    end
end

bot.on :message do |msg|
      commands.check_cmds(bot, msg, plug)

      responses = plug.check_all(msg, bot.admins, bot.backlog)
      responses.each { |a| bot.say(a) }

      case msg.message
      when /^#{bot.nick_name}[,:] (h|H)ello/ then
            bot.privmsg(msg.channel, "hi: #{msg.nick}")
      end
end

bot.setup(use_ssl, use_pass, pass, nickserv_pass, channels)
bot.start!