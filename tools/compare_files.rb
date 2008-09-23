#!/usr/bin/env ruby

f1p = ARGV[0]
f2p = ARGV[1]

file1 = []
file2 = []

IO.foreach(f1p) { |line| file1.push line }
file1 = file1.join("")

if f2p.nil?
  STDIN.each_line { |line| file2.push line }
else
  IO.foreach(f2p) { |line| file2.push line }
end
file2 = file2.join("")

print "-----\n",file1,"\n-----\n",file2,"\n-----\n"
if file1 == file2
  print "MATCH\n"
else
  print "FAIL\n"
end
