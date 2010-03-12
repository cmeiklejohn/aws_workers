#!/usr/bin/ruby

require 'rubygems'

q = Queue.new

puts q.size

t1 = Thread.new do
  q << "a"
  sleep 900000
  q.pop
end

t2 = Thread.new do 
  puts "t2: " + q.size.to_s
end

puts q.size
