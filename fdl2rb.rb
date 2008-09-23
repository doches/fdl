#!/usr/bin/ruby

input = ARGV[0]
if input.nil?
  print "Usage: ./fdl2rb.rb <input.fdl>"
end

`cat #{input} | parser/parser | ruby fdl2tree.rb | ruby tree2rb.rb`
