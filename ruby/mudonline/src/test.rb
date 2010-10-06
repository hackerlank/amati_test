#!/usr/bin/ruby
require "rubygems"
require "IRC"
require "socket"

class Master < IRC
  
  def initialize(nick, server, port, channels, options) 
    super(nick, server, port, nil, options)
    # Callbakcs for the connection.
    IRCEvent.add_callback("endofmotd") do |event| 
      channels.each { |chan| add_channel(chan) }
    end
    IRCEvent.add_callback("nicknameinuse") do |event| 
      ch_nick("RubyBot")
    end
    IRCEvent.add_callback("privmsg") do |event|
      parse(event)
    end
    IRCEvent.add_callback("join") do |event|
      if @autoops.include?(event.from)
        op(event.channel, event.from)
      end
    end
  end
  
  def parse(event)
    puts Thread.current
    target = (event.channel == @nick) ? event.from : event.channel
    msg = event.message
    
    case msg
    when /^(ciao|salve)$/i
      send_message(target, "Hello")
    end
  end
  
end


# Main

if __FILE__ == $0
  begin
    botnick  = "GameMaster"
    server   = "127.0.0.1"
    port     = "6667"
    channels = ["\#Hall"]
    options  = {} # {:use_ssl => 1}
    Master.new(botnick, server, port, channels, options).connect
  rescue Interrupt
  rescue Exception => e
    puts "MainLoop: " + e.message
    print e.backtrace.join("\n")
    #retry # ritenta dal begin
  ensure
  end
end
