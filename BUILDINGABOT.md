#**Bot Design Help**

> NOTE: reading the README first will be helpful

**To start**

- clone the repo
- create the folder for the bot
- copy the framework over
- create a directory for plugins
- [optional] copy over the plugins from rirc


            # windows git shell
            cd \path\to\your\git\folder\
            git clone https://github.com/The-Duchess/ruby-irc-framework
            mkdir <your bot folder>
            cd <your bot folder>
            cp ..\ruby-irc-framework\rirc.rb .\
            mkdir <your plugins folder>
            # optional
            cp ..\ruby-irc-framework\plugins\* .\<your plugins folder>\

            # linux with git in your path
            cd /path/to/your/git/folder/
            git clone https://github.com/The-Duchess/ruby-irc-framework
            mkdir -pv <your bot folder>
            cd <your bot folder>
            cp ../ruby-irc-framework/rirc.rb ./
            mkdir -pv <your plugins folder>
            # optional
            cp ../ruby-irc-framework/plugins/* ./<your plugins folder>/

**To create your bot**

- open up a programming text editor (i.e. Atom)
- include the framework
- then add configuration
- create the IRCBot
- [optional] create the plugin manager
- [optional] if using plugins setup plugins to auto-load
- [optional] if using plugins setup a hook on message to check all plugins
- then add customization
- then put in the connection info and start
- save the bot


Load the framework


```ruby
      require 'rirc.rb' # this line must be at the top of the file
```

Configuration


```ruby

      # you can setup configuration however you want
      # projects i have include bluckbot, which uses a set of files stored in a res folder,
      # and husk, which uses a module system.
      # but you are free to use whatever method works for you.

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

```

Create IRCBot


```ruby

      # Create the IRCBot object, or your irc client
      bot = IRCBot.new(network, port, nick, user_name, real_name)
      # Add admins to the IRCBOT object, or your irc client
      bot.set_admins(admins)
```

[optional] Create plugin manager


```ruby
      plug = Plugin_manager.new(plugin_folder)
```

[optional] Auto-load plugins


```ruby
      plugins_list.each { |a| plug.plugin_load(a) }
```

[optional] Add message hook for plugins


```ruby
      bot.on :message do |msg|
            responses = plug.check_all(msg, bot.admins, bot.backlog)
            responses.each { |a| bot.say(a) }
      end
```

Add custom behavior


```ruby
      # Add event hooks for custom code to be run
      # Check the README for more help
      bot.on :message do |msg|
            case msg.message
            when /^#{bot.nick_name}[,:] (h|H)ello/ then
                  bot.privmsg(msg.channel, "hi: #{msg.nick}")
            end
      end
```

[Advanced Custom Behavior]


The rirc framework supports a class


```ruby
      commands.Commands_manager.new
```

which allows you to add commands to the bot, that can:
- Tell the bot to do something
- Tell the bot to change state
- Control the Plugin manager

, that are set by regex


```ruby
	commands.on /^!join (\S+)/ do |ircbot, msg, pluginmgr|
	      channel = msg.message.split(" ")[1].to_s
	      ircbot.join(channel)
	end
```

The commands then have to be attached to a new, or can be placed in an existing bot.on, hook

> they can all be checked in one call.


```ruby
	bot.on :message do |msg|
		commands.check_cmds(bot, msg, plug)
	end
```

Start the bot


```ruby
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
```

Save the file to

      <your bot>.rb

**Running your bot**

      ruby <your bot>.rb
