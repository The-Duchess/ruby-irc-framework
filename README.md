# **Ruby IRC Framework**
**Version 0.3.1**

> The rirc [Framework](https://github.com/The-Duchess/ruby-irc-framework/blob/master/rirc.rb)

> Author: Alice "Duchess" Archer

> Copyright 2015 MIT License

> Copying:

> see [COPYING.md](https://github.com/The-Duchess/ruby-irc-framework/blob/master/COPYING.md)

# To Use

> place rirc.rb in the same directory as your main ircbot file


	load 'rirc.rb'

	ircbot = IRCBot.new(network, port, nick, user_name, real_name)

	# some setup

	until ircbot.socket.eof do
		# do some stuff
	end

> an [example bot](https://github.com/The-Duchess/ruby-irc-framework/blob/master/examplebot.rb) is provided

> a [functioning bot](https://github.com/The-Duchess/ruby-irc-framework/blob/master/demobot.rb) is provided

> a second [functioning bot](https://github.com/The-Duchess/ruby-irc-framework/blob/master/demobot2.rb) with easier setup is provided

> the functioning bot also supports use of an example [plugin](https://github.com/The-Duchess/ruby-irc-framework/blob/master/plugins/cat.rb)

> a full IRC bot [project](https://github.com/The-Duchess/husk) exists using this framework


# Classes Provided

**→ IRC_Message**

> created by ircbot.parse or initialized with message information

	msg = ircbot.read
	ircmsg = ircbot.parse(msg)
	# or
	ircmsg = IRC_message.new(command, nick, channel, message, ircmsg)

>Provides a structure to store irc messages in a parsed form

>Provides the functions assuming a message looks like

> :[nick]!~username@client [command] [channel] :[message]

- command, nick, channel, message to grab these elements of a message as well ircmsg to get the original message

- check_regex takes a type (command, nick, channel, message) and regex and returns true if the part of the message matches the regex


		ircmsg.check_regex("command", /^PRIVMSG$/)


- message_regex which just checks the message against a regex and returns true if the message matches the regex


		ircmsg.message_regex(/^!join /)


**→ IRCBot**

> initialized with connection information

	ircbot = IRCBot.new(network, port, nick, user_name, real_name)

>Provides a basic core irc bot

>Provides a number of functions for operation

- setup which takes the following arguments and connects and joins channels
>- bool to use ssl
>- bool to use a server pass
>- the server pass (can be "" if you do not want to use it)
>- the nickserv pass (can be "" if you do not want to use it)
>- an array of channels to join

		ircbot.setup(use_ssl, use_server_pass, server_pass, nickserv_pass, channels)

- start which starts the bot

		ircbot.start!

- on which allows you to register code to be run over and IRC_message object when the bot receives a message with the :message type. registered blocks are only used if you use ircbot.start(...) to run the bot


	```ruby
		ircbot.on :message do |msg|
			if msg.message_regex(/^#{ircbot.nick_name}[:,] (h|H)ello/)
				ircbot.privmsg(msg.channel, "Hi: #{msg.nick}")
			end
		end
	```


> three types exist for the on command

> the second [functioning bot](https://github.com/The-Duchess/ruby-irc-framework/blob/master/demobot2.rb) has example code using all of them


		```ruby
			# lets the bot do something on a message with IRC_message object the argument
			# useful for plugins
			ircbot.on :message do |msg|

			end

			# lets the bot do something on a message with channel and command as arguments
			# lets the bot respond to commands
			ircbot.on :command do |channel, command|

			end

			# lets the bot do something on a message
			# with the nick, command, channel, and message content as arguments
			ircbot.on :ircmsg do |nick, command, channel, message|

			end
		```

- network, port, nick_name, user_name, real_name, backlog and socket all return these respective values
> the backlog is updated automatically for you if using the following to run the bot

		ircbot.start!

- say which takes a message and prints it to the socket

		ircbot.say("PRIVMSG #chat :hello")

- join which takes a channel as a string and joins the channel and adds it to the currently active channels

		ircbot.join("#chat")

- connect which forms the initial connection

		ircbot.connect

- connect_ssl which adds the ssl wrapper to the active connection

		ircbot.connect_ssl

- connect_pass which takes a password as a string to connect to a network that requires a pass

		ircbot.connect_pass("pass")

- nick which takes a nick as a string and sets the bots nick and sends the information to the irc net

		ircbot.nick("rubybot")

- privmsg which takes a destination and a message and sends the message to the destination

		ircbot.privmsg("#chat", "hello")

- action which takes a destination and a message and performs an action at the location

		ircbot.action("#chat", "waves")

- notice is like privmsg but sends a notice to the location

		ircbot.notice("#chat", "I AM AN IRC BOT")

- ctcp makes a version request with a message to a destination

		ircbot.ctcp("#chat", "")

- part parts from a destination with the reason message

		ircbot.part("#chat", "this exchange is over")

- quit quits with the reason message

		ircbot.quit("this exchange is over")

- names gets names at a destination

		ircbot.names("#chat")

- identify takes a nickserv pass and identifies to nickserv with it

		ircbot.identify(nickserv_pass)

- auth sets user, real name and nick and if the nickserv_pass passed to auth is not empty or nil then it identifies to nickserv with nickserv_pass

		ircbot.auth(nickserv_pass)

- read reads a line from the socket and PONGs if it sees a PING else it will return the message line

		msg = ircbot.read

- parse parses a message into a new IRC_message object

		msg = ircbot.parse(ircbot.read)

- add_admin and remove_admin adds and removes admins by nick

		ircbot.add_admin("apels")
		ircbot.remove_admin("apels")

- set_admins and join_channels which take arrays of admins and channels respectively and add and join respectively

		ircbot.set_admins(["apels"])
		ircbot.join_channels(["#chat"])

**→ Plugin_manager**

> initialized with the plugin folder file path

	pluginmgr = Plugin_manager.new("/path/to/plugin/folder")

> Plugins based on the [plugin template](https://github.com/The-Duchess/ruby-irc-framework/blob/master/exampleplugin.rb) the framework supports for plugin management.

> The plugin template will tell you what parts are neccessary for creating a plugin.

> Two functional plugins are provided

>- [YouTube](https://github.com/The-Duchess/ruby-irc-framework/blob/master/plugins/youtube.rb)

>> NOTE: YouTube will require some gems

>- [Cat](https://github.com/The-Duchess/ruby-irc-framework/blob/master/plugins/cat.rb)

> Provided Functions

> fetching functions

- plugins returns the array of currently loaded plugins

		new_plugin_list = pluginmgr.plugins

- get_names gets an array of strings of the names of all loaded plugins

		plugin_names = pluginmgr.get_names

- get_helps gets an array of strings of the help of all loaded plugins

		plugin_helps = pluginmgr.get_helps

- get_files gets an array of plugin file names of all loaded plugins

		plugin_file_names = pluginmgr.get_files

- get_chans gets an array of plugin channels (array) of all loaded plugins

		plugin_chans = pluginmgr.get_chans

- get_regexps gets an array of plugin regexes of all loaded plugins

		plugin_regexps = pluginmgr.get_regexps

> search functions

- get_plugin gets a plugin by name and returns a Plugin object or nil if the plugin is not loaded

		temp_plugin = pluginmgr.get_plugin("name")

- plugin_help gets a plugin's help by name or nil if the plugin is not loaded

		temp_help = pluginmgr.plugin_help("name")

- plugin_file_name gets a plugin's file name by name or nil if the plugin is not loaded

		temp_file_name = pluginmgr.plugin_file_name("name")

- plugin_chans gets a plugin's channel list by name or nil if the plugin is not loaded

		temp_chans = pluginmgr.plugin_chans("name")

- plugin_regex gets a plugin's regex by name or nil if the plugin is not loaded

		temp_regex = pluginmgr.plugin_regex("name")

- plugin_loaded checks if a plugin is loaded by name and returns true if it is loaded

		if pluginmgr.plugin_loaded("name") then return true end

> regex functions

- check_plugin

		temp_response = pluginmgr.check_plugin("name", ircmessage, ["apels"], [])


> inputs:

>  ↰ plugin name

>  ↰ IRC_message object [to check against the plugin's regex and use in used plugins]

>  ↰ array of admins [can be an empty array]

>  ↰ backlog array of IRC_message objects [can be an empty array]

> output:

>  ↳ string to be sent to the socket (i.e "PRIVMSG #chat :hi")

- check_all

		temp_responses = pluginmgr.check_all(ircmessage, ["apels"], [])

> inputs:

>  ↰ IRC_message object [to check against the plugin's regex and use in used plugins]

>  ↰ array of admins [can be an empty array]

>  ↰ backlog array of IRC_message objects [can be an empty array]

> output:

>  ↳ array of strings returned from check_plugin

> plugin loading, unloading and reloading

- plugin_load loads a plugin by file name (with or without the .rb extension) in the plugin folder

		pluginmgr.plugin_load("name.rb")
		pluginmgr.plugin_load("name")

- unload unloads a plugin by name

		pluginmgr.unload("name")

- reload reloads a plugin by name

		pluginmgr.reload("name")
