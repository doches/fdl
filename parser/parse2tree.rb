#!/usr/bin/ruby
require 'yaml'

class Node
  attr_accessor :type,:string,:left,:right,:indent,:key
  def initialize(fline)
    @indent = fline[0]
    @key,@type,@string,@left,@right = fline[1].strip.split(":")
  end
  
  def to_s
    str = ""
    @indent.times { str += " " }
    str += "#{@type}:[#{@string}]"
  end
end

if __FILE__ == $0

# Split STDIN into array of features
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
    node = Node.new(fline)
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

end
