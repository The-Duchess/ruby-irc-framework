# **Ruby IRC Framework**

> The rirc [Framework](https://github.com/The-Duchess/ruby-irc-framework/blob/master/rirc.rb)

> Author: Alice "Duchess" Archer

> Copyright 2015 MIT License

> Copying:

> see COPYING.md

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

> the functioning bot also supports use of an example [plugin](https://github.com/The-Duchess/ruby-irc-framework/blob/master/plugins/cat.rb)

# Classes Provided

**→ IRC_Message**

> created by ircbot.parse or initialized with message information

	msg = ircbot.read
	ircbot.parse(msg)
	# or
	ircmsg = IRC_message.new(command, nick, channel, message)

>Provides a structure to store irc messages in a parsed form

>Provides the functions

>- command, nick, channel, message to grab these elements of a message

>- check_regex takes a type (command, nick, channel, message) and regex and returns if the string matches the regex

	ircmsg.check_regex("command", /^PRIVMSG$/)

>- message_regex which just checks the message (param) against a regex

	ircmsg.message_regex(/^!join /)

**→ IRCBot**

> initialized with connection information

	ircbot = IRCBot.new(network, port, nick, user_name, real_name)

>Provides a basic core irc bot

>Provides a number of functions for operation

>- network, port, nick_name, user_name, real_name and socket all return these respective values

>- say which takes a message and prints it to the socket

	ircbot.say("PRIVMSG #chat :hello")

>- join which takes a channel as a string and joins the channel and adds it to the currently active channels

	ircbot.join("#chat")

>- connect which forms the initial connection

	ircbot.connect

>- connect_ssl which adds the ssl wrapper to the active connection

	ircbot.connect_ssl

>- connect_pass which takes a password as a string to connect to a network that requires a pass

	ircbot.connect_pass("pass")

>- nick which takes a nick as a string and sets the bots nick and sends the information to the irc net

	ircbot.nick("rubybot")

>- privmsg which takes a destination and a message and sends the message to the destination

	ircbot.privmsg("#chat", "hello")

>- action which takes a destination and a message and performs an action at the location

	ircbot.action("#chat", "waves")

>- notice is like privmsg but sends a notice to the location

	ircbot.notice("#chat", "I AM AN IRC BOT")

>- ctcp makes a version request with a message to a destination

	ircbot.ctcp("#chat", "")

>- part parts from a destination with the reason message

	ircbot.part("#chat", "this exchange is over")

>- quit quits with the reason message

	ircbot.quit("this exchange is over")

>- names gets names at a destination

	ircbot.names("#chat")

>- auth sets user, real name and nick and if there is a nickserv pass then it identifies

	ircbot.auth

>- read reads a line from the socket and PONGs if it sees a PING else it will return the message line

	msg = ircbot.read

>- parse parses a message into a new IRC_message object

	msg = ircbot.parse(ircbot.read)

>- add_admin and remove_admin adds and removes admins by nick

	ircbot.add_admin("apels")
	ircbot.remove_admin("apels")

**→ Plugin_manager**

> initialized with the plugin folder file path

	pluginmgr = Plugin_manager.new("/path/to/plugin/folder")

> Plugins based on the [plugin template](https://github.com/The-Duchess/ruby-irc-framework/blob/master/exampleplugin.rb) the framework supports for plugin management.

> Provided fuctions

>- plugins returns the array of Plugin objects

	new_plugin_list = pluginmgr.plugins

> search functions

>- get_plugin gets a plugin by name and returns a Plugin object or nil if the plugin is not loaded

	temp_plugin = pluginmgr.get_plugin("name")

>- plugin_help gets a plugin's help by name

	temp_help = pluginmgr.plugin_help("name")

>- plugin_file_name gets a plugin's file name by name

	temp_file_name = pluginmgr.plugin_file_name("name")

>- plugin_chans gets a plugin's channel list by name

	temp_chans = pluginmgr.plugin_chans("name")

>- plugin_regex gets a plugin's regex by name

	temp_regex = pluginmgr.plugin_regex("name")

>- plugin_loaded checks if a plugin is loaded by name

	if pluginmgr.plugin_loaded("name") then return true end

> regex functions

>- check_plugin

	temp_response = pluginmgr.check_plugin("name", ircmessage, ["apels"], [])


>> this function uses the IRC_message object for message input

>> inputs:

>>  ↪ name

>>  ↪ IRC_message object

>>  ↪ array of admins [can be an empty array]

>>  ↪ backlog array of IRC_message objects [can be an empty array]

>> output: string

>- check_all

	temp_responses = pluginmgr.check_all(ircmessage, ["apels"], [])

>> this function uses the IRC_message object for message input

>> regex check function that returns responses for loaded plugins

>> inputs:

>>  ↪ IRC_message object

>>  ↪ array of admins [can be an empty array]

>>  ↪ backlog array of IRC_message objects [can be an empty array]

>> output: array of strings

> plugin loading, unloading and reloading

>- plugin_load loads a plugin by file name (with or without the .rb extension) in the plugin folder

	pluginmgr.load("name.rb")
	pluginmgr.load("name")

>- unload unloads a plugin by name

	pluginmgr.unload("name")

>- reload reloads a plugin by name

	pluginmgr.reload("name")
