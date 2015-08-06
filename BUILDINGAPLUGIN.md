#**Plugin Design Help**

This help is presented to help you understand the plugin system and to easily build plugins using the rirc framework.

> NOTE: reading the README first will be helpful

> NOTE: the example [plugin](https://github.com/The-Duchess/ruby-irc-framework/blob/master/exampleplugin.rb) has comments on the parts of the plugin which may be useful

**To Start**

> NOTE: This will assume you have a bot already created and thus you have a plugins folder.

- Open the folder your bot you saved in in a programming text editor (i.e. Atom)
- Enter the skeleton code for a plugin in a new file you will save in the plugins folder


```ruby
            load 'rirc.rb'

            module Loadable_Plugin
            	class Template < Pluginf

            		def script(message, admins, backlog)

            			return ""
            		end
            	end

            	def initialize
            		@reg = // # regex to call the plugin
            		@filename = "" # file name
            		@pluginname = "" # name for plugin
            		@description = "" # description and or help
            		@plugin = Template.new(@reg, @pluginname, @filename, @description)
            	end

            	def get_plugin
            		return @plugin
            	end
            end

            class Loader
            	include Loadable_Plugin
            end
```

> The plugin system uses a module with the same name that is contained in a class definition that always uses the same name. This allows the lazy evaluation of ruby to circumvent the inability to share local variables between files that would otherwise require using globals, which are a horrible idea to use in a framework.

- Save the file now so you know what your file name will be as this is stored by the plugin for reloading
- Edit the parts of the plugin that can and need to be changed to give the functionality you want

>- [optional but a good idea] class name however do not remove the inheritance of the default plugin
>- the plugin class' script function which is called using polymorphism (you cannot change the arguments)
>- add any functions you may need to the class
>- [optional] editing the initialization function for the class (this will be covered at the end)
>- initialize function to set internal variables for the plugin. these control

>>- regex that will trigger the plugin being called on a message

>>- file name that allows the plugin manager to reload the correct plugin

>>- plugin name that people access help with, unload the module with, and see if you implement a way to list loaded plugins

>>- description which gives a simple explanation of the plugin and or usage

>>- the creation of an instance of the plugin class which will trigger when the plugin is loaded and handed back from the loader


**plugin script function**

inputs

- IRC_message object
- admins array
- backlog array of IRC_message objects arranged from least recent to most recent


output

- raw string to be sent to the socket


```ruby
            # your definition for function called if the regex for the plugin matches the message.message
            # NOTE:
            # DO NOT CHANGE THE NAME OR ARGUMENTS TO THIS FUNCTION
            # YOUR PLUGIN WILL NOT WORK
            def script(message, admins, backlog)

                  # plugins must return the raw message they wish to have sent to the socket
                  # return "PRIVMSG #{message.chan} :hello"
                  # or you can use functions to simplify this
                  # an example for privmsg is provided below
                  return privmsg(message.channel, "hello")
            end

            def privmsg(dest, message)
                  return "PRIVMSG #{dest} :#{message}"
            end
```


**plugin variables**

regex


```ruby
      @reg = //
```

file name


```ruby
      @filename = "<your plugin>.rb"
```


plugin name


```ruby
      @pluginname = "<your plugin>"
```

description


```ruby
      @description = "this plugin responds to #{@reg.to_s} and ....."
```

- Save the file again

**Summary**

The plugin system allows you to edit the script function along with some simple variables to easily create functionality.

**Advanced**

You also have access to a number of built in functions inside the default plugin class which all plugins inherit.

- The ability to redefine the initialization function
- The ability to specify what happens when the plugin is unloaded (also reloaded since plugins are fully unloaded when reload is run)

> Default initialization code

> you can add other instance variables here instead of just adding class variables as well as have specific calls when the plugin is loaded (i.e. loading config files)

```ruby
      def initialize(regex, name, file_name, help)
            @regexp = Regexp.new(regex.to_s)
            @name = name.to_s
            @file_name = file_name.to_s
            @help = help
            @chan_list = []
            @chan_list.push("any")
      end
```

> Code that is called when a plugin is unloaded

> you can redefine this function to perform state save or other calls when the plugin is unloaded

```ruby
      def cleanup
            return ""
      end
```
