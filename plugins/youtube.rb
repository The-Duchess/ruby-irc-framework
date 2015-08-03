#!/bin/env ruby
#############################################################################################
# author: apels <Alice Duchess>
#############################################################################################

# note: example code does not actually run
# a running example should be posted soon

require 'google/api_client'
require 'json'
require 'uri'
require 'net/http'
require 'multi_json'
require 'date'

load 'rirc.rb'

class Youtube < Pluginf

	# any functions you may need can be included here

	# your definition for function called if the regex for the plugin matches the message.message
	# inputs:
	# 	- IRC_message object
	# 	- admins array
	# 	- backlog array of IRC_message objects
	# output: string to send to the socket
	def script(message, admins, backlog)

            video_n = ""

		if message.message.include? "="
			video_n = message.message.split("=")[1].to_s.split(" ")[0].to_s
		else
			video_n = message.message.split(".be")[1].to_s[1..-1].to_s
		end

		response = "\x031,0You\x030,4Tube\x03 "
		result = Hash.new

		client = Google::APIClient.new
		youtube = client.discovered_api('youtube', 'v3')
		client.authorization = nil
		result = client.execute :key => "AIzaSyAg8UUsu7u4mf7UzKqIAMmBSoW2Ms50YZM", :api_method => youtube.videos.list, :parameters => {:id => "#{video_n}", :part => 'contentDetails,statistics,snippet'}
		result = JSON.parse(result.data.to_json)

		begin
			video_i = result.fetch('items')[0].fetch('snippet')
		rescue NoMethodError => e
			return "video could not be queried"
		end

		video_c = result.fetch('items')[0].fetch('contentDetails')
		video_s = result.fetch('items')[0].fetch('statistics')

		duration = video_c.fetch('duration').match(/^PT((?<hours>[0-9]+)H)?((?<minutes>[0-9]+)M)?((?<seconds>[0-9]+)S)?$/)
		duration = duration[:hours].to_i * 3600 + duration[:minutes].to_i * 60 + duration[:seconds].to_i
		durat = Time.at(duration).utc.strftime("%H:%M:%S")

		viewc = video_s.fetch('viewCount').to_s
		likes = video_s.fetch('likeCount').to_s
		dislikes = video_s.fetch('dislikeCount').to_s

		response.concat("「\x032title:\x03 #{video_i.fetch('title').to_s}」 ")
		response.concat("「\x032uploaded by:\x03 #{video_i.fetch('channelTitle').to_s}」 ")
		response.concat("「\x032duration:\x03 #{durat}」 ")
		response.concat("「\x032views:\x03 #{viewc}」 「\x032likes:\x03 #{likes}」 「\x032dislikes:\x03 #{dislikes}」")

		description = video_i.fetch('description')[0..500].to_s.split("\n")
		des = ""
		description.each {|a| des.concat("#{a}\. ")}

		#response.concat(" 「description: #{des[0..69]}\.\.\.」")
		# plugins must return the raw mesaage they wish to have sent to the socket
		# return "PRIVMSG #{message.chan} :hello"
		# or you can use functions to simplify this
		# some are provided below
		return privmsg(message.channel, response)
	end

	def privmsg(dest, message)
		return "PRIVMSG #{dest} :#{message}"
	end

	def action(dest, message)
		return "PRIVMSG #{dest} :\01ACTION\07\01 #{message}"
	end

	def notice(dest, message)
		return "NOTICE #{dest} :#{message}"
	end
end

# allows you to support multiple regexes
# prefix = [
#		//,
#		//
#	   ]
#
# reg_p = Regexp.union(prefix)

# information the plugin needs to be initialized with
reg = /(?:https?:\/\/)?(?:www\.)?youtu(?:\.be|be\.com)\/(?:watch\?v=)?([\w-]{10,})/ # regex to call the plugin
filename = "youtube.rb" # file name
pluginname = "YouTube" # name for plugin
description = "detects youtube links and gets the meta data for the vid" # description and or help

# plugin = Class_name.new(regex, name, file_name, help)
# this temporary global is used for handing the new plugin back to the bot
module Loadable_Plugin
	temp = Youtube.new(reg, pluginname, filename, description)
end
