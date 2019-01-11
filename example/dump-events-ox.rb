#!/usr/bin/env ruby

require 'asterisk/ajam'
require 'ox'
require 'pry'
require 'pp'

ajam = Asterisk::AJAM.connect uri:          ENV['AMI_URI'],
                              ami_user:     ENV['AMI_USER'],
                              ami_password: ENV['AMI_PASSWORD']

if ajam.connected?
  ajam.command 'dialplan reload'
  res = ajam.action_sippeers
  res.list.each {|peer| puts peer['objectname']}
end

# Keep ajam connected!
Thread.start do
  loop do
    puts "\nPING!\n"
    if ajam.action_ping.attribute['response'] == 'Error'
      puts "\n\n\nSomething with AJAM connection, terminating\n"
      exit
    end
    sleep 5
  end
end

loop do
  begin
    data = nil
    events = ajam.action_waitevent
    data = Ox.load(events.raw_xml, mode: :hash)
    data = data[:'ajax-response'][:response]

    data = data.map do |records|
      records.map do |record|
        ( record[:generic] || {} ).map do |event|
          event if event.has_key?(:event) && event[:event] != 'WaitEventComplete'
        end.compact
      end
    end.flatten

    puts "Got #{data.count} records:\n#{data.pretty_inspect}\n------------------\n"
  rescue => e
    puts "ERROR: #{e}, data:\n#{data.inspect}"
  end
end

# binding.pry
# puts "Bye!"
