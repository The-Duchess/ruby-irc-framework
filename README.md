# **Ruby IRC Framework**
**Version 0.6.3**

**Important Notes**

>- The Plugins system changed after 0.3.4 but is no longer receiving updates that will affect compatibility.

>- The Commands_manager is no longer receiving updates that will affect compatibility.

**About**

> The rirc [Framework](https://github.com/The-Duchess/ruby-irc-framework/blob/master/rirc.rb)

> Author: Alice "Duchess" Archer

> Copyright 2015 MIT License

> Copying:

> see [COPYING.md](https://github.com/The-Duchess/ruby-irc-framework/blob/master/COPYING.md)

# To Use

Place rirc.rb in the same directory as your main ircbot file



```ruby
	require_relative 'rirc.rb'

	ircbot = IRCBot.new(network, port, nick, user_name, real_name)
	bot.set_admins(admins)

	bot.on :message do |msg|
	      case msg.message
	      when /^#{bot.nick_name}[,:] (h|H)ello/ then
	            bot.privmsg(msg.channel, "hi: #{msg.nick}")
	      end
	end

	bot.setup(use_ssl, use_pass, pass, nickserv_pass, channels)
	bot.start!
```

> for further help building a bot check this [help](https://github.com/The-Duchess/ruby-irc-framework/blob/master/BUILDINGABOT.md)

> if you have a working bot folder and plugins folder and want to make plugins check this [help](https://github.com/The-Duchess/ruby-irc-framework/blob/master/BUILDINGAPLUGIN.md)

> a [functioning bot](https://github.com/The-Duchess/ruby-irc-framework/blob/master/demobot.rb) is provided

> the functioning bot also supports use of an example [plugin](https://github.com/The-Duchess/ruby-irc-framework/blob/master/plugins/cat.rb)

> a rudimentary [irc client](https://github.com/The-Duchess/ruby-irc-framework/blob/master/ircclient.rb) exists using this framework

> a full IRC bot [project](https://github.com/The-Duchess/husk) exists using this framework


# Objects Provided

**IRC_Message**

Created by ircbot.parse or initialized with message information


```ruby
	msg = ircbot.read
	ircmsg = ircbot.parse(msg)
	# or
	ircmsg = IRC_message.new(command, nick, channel, message, msg)
```

*Provides a structure to store irc messages in a parsed form*

*Provides the functions assuming a message looks like*

> :[nick]!~username@client [command] [channel] :[message]

- command, nick, channel, message to grab these elements of a message as well ircmsg to get the original message

- check_regex takes a type (command, nick, channel, message) and regex and returns true if the part of the message matches the regex


```ruby
	ircmsg.check_regex("command", /^PRIVMSG$/)
```

- message_regex which just checks the message against a regex and returns true if the message matches the regex


```ruby
	ircmsg.message_regex(/^!join (\S+)/)
```

**IRCBot**

Initialized with connection information


```ruby
	ircbot = IRCBot.new(network, port, nick, user_name, real_name)
```

*Provides a basic core irc bot*

*Provides a number of functions for operation*


- setup which takes the following arguments and connects and joins channels

>- bool to use ssl
>- bool to use a server pass
>- the server pass (can be "" if you do not want to use it)
>- the nickserv pass (can be "" if you do not want to use it)
>- an array of channels to join

> setup creates 2 log files

>- ./log which logs messages that are saved on Command_manager hooks as well as private messages
>- ./errlog which records errors


```ruby
	ircbot.setup(use_ssl, use_server_pass, server_pass, nickserv_pass, channels)
```

- start! which starts the bot


```ruby
	ircbot.start!
```

- on which allows you to create hooks to blocks of code for different purposes that are covered in the below code.

> the priority in which they are checked is 1) commands, 2) message, 3) ircmsg


```ruby
	ircbot.on :message do |msg|
		if msg.message_regex(/^#{ircbot.nick_name}[:,] (h|H)ello/)
			ircbot.privmsg(msg.channel, "Hi: #{msg.nick}")
		end
	end

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

the backlog is updated automatically for you if use bot.start!


```ruby
	ircbot.start!
```

- say which takes a message and prints it to the socket


```ruby
	ircbot.say("PRIVMSG #chat :hello")
```

- join which takes a channel as a string and joins the channel and adds it to the currently active channels


```ruby
	ircbot.join("#chat")
```

- connect which forms the initial connection


```ruby
	ircbot.connect
```

- connect_ssl which adds the ssl wrapper to the active connection


```ruby
	ircbot.connect_ssl
```

- connect_pass which takes a password as a string to connect to a network that requires a pass


```ruby
	ircbot.connect_pass("pass")
```

- nick which takes a nick as a string and sets the bots nick and sends the information to the irc net


```ruby
	ircbot.nick("rubybot")
```

- privmsg which takes a destination and a message and sends the message to the destination


```ruby
	ircbot.privmsg("#chat", "hello")
```

- action which takes a destination and a message and performs an action at the location


```ruby
	ircbot.action("#chat", "waves")
```

- notice is like privmsg but sends a notice to the location


```ruby
	ircbot.notice("#chat", "I AM AN IRC BOT")
```

- ctcp makes a version request with a message to a destination


```ruby
	ircbot.ctcp("dest", "")
```

- part parts from a destination with the reason message


```ruby
	ircbot.part("#chat", "this exchange is over")
```

- rm_chan which takes a channel and removes it from the IRCBot active channel list.


```ruby
	ircbot.rm_chan(channel)
```

- add_chan which takes a channel and adds it to the IRCBot active channel list.


```ruby
	ircbot.add_chan(channel)
```

- quit quits with the reason message


```ruby
	ircbot.quit("this exchange is over")
```

- names gets names at a destination


```ruby
	ircbot.names("#chat")
```

- identify takes a nickserv pass and identifies to nickserv with it


```ruby
	ircbot.identify(nickserv_pass)
```

- auth sets user, real name and nick and if the nickserv_pass passed to auth is not empty or nil then it identifies to nickserv with nickserv_pass


```ruby
	ircbot.auth(nickserv_pass)
```

- read reads a line from the socket and PONGs if it sees a PING else it will return the message line


```ruby
	msg = ircbot.read
```

- parse parses a message into a new IRC_message object

```ruby
	msg = ircbot.parse(ircbot.read)
```

- add_admin and remove_admin adds and removes admins by nick


```ruby
	ircbot.add_admin("apels")
	ircbot.remove_admin("apels")
```

- set_admins and join_channels which take arrays of admins and channels respectively and add and join respectively


```ruby
	ircbot.set_admins(["apels"])
	ircbot.join_channels(["#chat"])
```

**Plugin_manager**

Initialized with the plugin folder file path


```ruby
	pluginmgr = Plugin_manager.new("/path/to/plugin/folder")
```

Plugins based on the [plugin template](https://github.com/The-Duchess/ruby-irc-framework/blob/master/exampleplugin.rb) the framework supports for plugin management.

The plugin template will tell you what parts are neccessary for creating a plugin.

Two functional plugins are provided

>- [YouTube](https://github.com/The-Duchess/ruby-irc-framework/blob/master/plugins/youtube.rb)

>> NOTE: YouTube will require some gems

>- [Cat](https://github.com/The-Duchess/ruby-irc-framework/blob/master/plugins/cat.rb)

*Provided Functions*

_fetching functions_

- plugins returns the array of currently loaded plugins


```ruby
	new_plugin_list = pluginmgr.plugins
```

- get_names gets an array of strings of the names of all loaded plugins


```ruby
	plugin_names = pluginmgr.get_names
```

- get_helps gets an array of strings of the help of all loaded plugins


```ruby
	plugin_helps = pluginmgr.get_helps
```

- get_files gets an array of plugin file names of all loaded plugins


```ruby
	plugin_file_names = pluginmgr.get_files
```

- get_chans gets an array of plugin channels (array) of all loaded plugins


```ruby
	plugin_chans = pluginmgr.get_chans
```

- get_chans has an alternate function to get chans for a plugin by name gets an array of plugin channels (array) of a loaded plugin by name


```ruby
	plugin_chans = pluginmgr.get_chans("name")
```

- get_regexps gets an array of plugin regexes of all loaded plugins


```ruby
	plugin_regexps = pluginmgr.get_regexps
```

_search functions_

- get_plugin gets a plugin by name and returns a Plugin object or nil if the plugin is not loaded


```ruby
	temp_plugin = pluginmgr.get_plugin("name")
```

- plugin_help gets a plugin's help by name or nil if the plugin is not loaded


```ruby
	temp_help = pluginmgr.plugin_help("name")
```

- plugin_file_name gets a plugin's file name by name or nil if the plugin is not loaded


```ruby
	temp_file_name = pluginmgr.plugin_file_name("name")
```

- plugin_chans gets a plugin's channel list by name or nil if the plugin is not loaded


```ruby
	temp_chans = pluginmgr.plugin_chans("name")
```

- plugin_regex gets a plugin's regex by name or nil if the plugin is not loaded


```ruby
	temp_regex = pluginmgr.plugin_regex("name")
```

- plugin_loaded checks if a plugin is loaded by name and returns true if it is loaded


```ruby
	if pluginmgr.plugin_loaded("name") then return true end
```

- add_chan takes a plugin name and a channel and adds the channel to the plugin's allowed channel list


```ruby
	pluginmgr.add_chan("name", "#chat")

```

- add_chan_clear_any takes a plugin name and a channel and adds the channel to the plugin's allowed channel list but also removes the option from a plugin that allows it to be used in any channel.


```ruby
	pluginmgr.add_chan_clear_any("name", "#chat")
	# the removal of thee any option can be restored with add_chan
	pluginmgr.add_chan("name", "any")
```

- rm_chan removes a channel from the allowed channel list


```ruby
	pluginmgr.rm_chan("name", "#chat")

```

_regex functions_

- check_plugin checks a plugin against the irc message and runs the plugin's script function if the plugin's regex matches the irc message and it is allowed to be used in the channel the irc message was sent.


```ruby
	temp_response = pluginmgr.check_plugin("name", ircmessage, ["apels"], [])
```

inputs:

>  plugin name

>  IRC_message object [to check against the plugin's regex and use in used plugins]

>  array of admins [can be an empty array]

>  backlog array of IRC_message objects [can be an empty array]

output:

>  string to be sent to the socket (i.e "PRIVMSG #chat :hi")

- check_all


```ruby
	temp_responses = pluginmgr.check_all(ircmessage, ["apels"], [])
```

inputs:

>  IRC_message object [to check against the plugin's regex and use in used plugins]

>  array of admins [can be an empty array]

>  backlog array of IRC_message objects [can be an empty array]

output:

>  array of strings returned from check_plugin

> plugin loading, unloading and reloading

- plugin_load loads a plugin by file name (with or without the .rb extension) in the plugin folder


```ruby
	pluginmgr.plugin_load("name.rb")
	pluginmgr.plugin_load("name")
```

- unload unloads a plugin by name


```ruby
	pluginmgr.unload("name")
```

- reload reloads a plugin by name


```ruby
	pluginmgr.reload("name")
```

**Command_manager**

This feature allows you to make commands by regex that can:
- Tell the bot to do something
- Tell the bot to change state
- Control the Plugin manager
- write to the ./log file when a hook is used


```ruby
	cmnd = Command_manager.new
```

The command manager is a hook system like the ircbot's on function. It requires you to add a check to a new ircbot hook or place it in an existing one.


```ruby
	ircbot.on :message do |msg|
		cmnd.check_cmds(ircbot, msg, pluginmgr)
	end
```

> Example command hook:

```ruby
	cmnd.on /^!join (\S+)/ do |ircbot, msg, pluginmgr|
	      channel = msg.message.split(" ")[1].to_s
	      ircbot.join(channel)
	end
```

The command hooks create blocks of code that are triggered on the regex and are given the arguments:

- ircbot: an IRCBot instance

- msg: an IRC_message object

- pluginmgr: a Plugin_manager instance
