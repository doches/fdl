#!/usr/bin/env ruby

=begin

generate.rb is a convenience tool that chains together the tools fdl2tree.rb
and tree2rb.rb.

Trevor Fountain, 10 October 2008

=end

require 'optparse'
require 'ostruct'

options = OpenStruct.new
options.editor = nil
optparser = OptionParser.new do |opts|
  opts.banner = "Usage: ./generate.rb path/to/file.fdl [options]"
  
  opts.on("-e", "--edit [EDITOR]",
          "View the output in EDITOR",
          "  (defaults to $EDITOR if no editor is supplied)") do |editor|
    options.editor = editor || ENV['EDITOR']
  end
  
  opts.on_tail("-h","--help","Show this help text") do
    puts opts
    exit
  end
end

optparser.parse!

feature = ARGV[0]
if feature.nil?
  puts "No feature file specified!"
  puts optparser
  exit(1)
end

if feature[feature.size-4..feature.size] == ".fdl"
  feature = feature[0..feature.size-5]
end

output = %x{cat #{feature}.fdl | parser/parser}
# | ./fdl2tree.rb | ./tree2rb.rb > #{feature}.rb`
if $?.exitstatus == 0
  output = %x{echo "#{output}" | ./fdl2tree.rb | ./tree2rb.rb > #{feature}.rb}
  exec("#{options.editor} #{feature}.rb") if not options.editor.nil? and $?.exitstatus == 0
end
