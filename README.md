# **ruby-irc-framework**

# Classes Provided

- IRC_Message

>Provides a structure to store irc messages in a parsed form

>Provides the functions

>- command, nick, channel, message to grab these elements of a message

>- check_regex takes a type (command, nick, channel, message) and regex and returns if the string matches the regex

	ircmsg.check_regex("command", /^PRIVMSG$/)

>- message_regex which just checks the message (param) against a regex

	ircmsg.message_regex(/^`join /)

- IRCBot

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

and [example bot](https://github.com/The-Duchess/ruby-irc-framework/blob/master/examplebot.rb) is provided
