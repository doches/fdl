#!/usr/bin/env ruby
feature = ARGV[0]
if feature.nil?
  print "Usage: ./generate.rb <featurename> [-noedit]\n"
  exit(1)
end

if feature[feature.size-4..feature.size] == ".fdl"
  feature = feature[0..feature.size-5]
end

editor = ENV['EDITOR']
editor ||= "nano"

output = %x{cat #{feature}.fdl | parser/parser}
# | ./fdl2tree.rb | ./tree2rb.rb > #{feature}.rb`
if $?.exitstatus == 0
  output = %x{echo "#{output}" | ./fdl2tree.rb | ./tree2rb.rb > #{feature}.rb}
  exec("#{editor} #{feature}.rb") if ARGV[1].nil? and $?.exitstatus == 0
end
