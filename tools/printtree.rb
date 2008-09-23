#!/usr/bin/ruby
require 'yaml'
require 'lib/node'

YAML.load( STDIN ).each {|x| x.print_tree}
