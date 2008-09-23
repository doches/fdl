#!/usr/bin/ruby
require 'yaml'
require 'lib/node'

# Split input into array of features
features = []
feature = []
STDIN.each_line { |line|
  if line.strip.size <= 0
    features.push feature
    feature = []
  else
    feature.push [line.index(/[^\s]/),line]
  end
}

#Convert features into trees
trees = []
features.each { |feature|
  nodes = {}
  head = nil
  feature.each { |fline|
    node = FDL::Node.new(fline)
    nodes[node.key] = node
    
    head ||= node
  }
  nodes.each { |key,node|
    node.left = nodes[node.left]
    node.right = nodes[node.right]
  }
  trees.push head
}

print trees.to_yaml
