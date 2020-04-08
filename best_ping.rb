#!/usr/bin/env ruby

require 'net/ping'
require 'uri'

mirrors = {}

File.foreach("mirrorslist.txt") do |line|
	if line.match(/\A#Server = http/)
		mirror = URI.parse(line.sub('#Server = ', '').delete("\n")).host
		icmp = Net::Ping::External.new(mirror)
		rtary = []
		pingfails = 0
		repeat = 5
		puts "starting to ping: #{mirror}"
		if icmp.ping
			rtary << icmp.duration
		else
			pingfails += 1
			# puts "timeout"
		end
		avg = rtary.inject(0) {|sum, i| sum + i}/(repeat - pingfails)
		avg = 999999 if avg == 0
		mirrors[line.delete("\n")] = avg
		puts "Average round-trip is #{avg}\n"
		puts "#{pingfails} packets were droped"
	end
end

open('myfile.out', 'w') { |f|
  write = mirrors.sort_by{|k, v| v}
  write.each do |line|
  	f.puts line[0]
  	puts "#{line[0]} - #{line[1]}"
  end
}

puts [mirrors.min_by{|k, v| v}].to_h
