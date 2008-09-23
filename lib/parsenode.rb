require 'lib/parsenodeset.rb'

# Make this less dumb.
# Damn, this is dumb.
def rand_range(min,max)
  x = min+rand
  while not (x >= min and x <= max)
    x = (rand * (max - min + 1)) + min
  end
  return x
end

# An individual node in the parse tree. Used by xml2pt.rb
class ParseNode < Hash
  include Comparable
  attr_accessor :children,:parent
  
  def initialize
    super
    
    @children = ParseNodeSet.new()
    self[:is] = self
  end
  
  def <=>(other)
    self[:index] <=> other[:index]
  end
  
  # Get nodes along the specified path matching the provided block
  def traverse(operator,match)
    ParseNodeSet.new(self).traverse(operator,match)
  end
  
  # Assign indices to this node and its children, for left/right-of operators.
  # TODO: I'm sure this can be done better. Improve it! 
  def generate_indices(index=1.0,left=nil,right=nil)
    if not index.nil?
      raise "index #{index} < left #{left}!" if not left.nil? and index < left
      raise "index #{index} > right #{right}!" if not right.nil? and index > right
    end
    self[:index] = index
    
    left = index - 1.0 if left.nil?
    right = index + 1.0 if right.nil?
    
    lefts = []
    center = []
    rights = []
    # indices < index
    (@children.size/2).times { 
      lefts.push rand_range(left+0.00001,index-0.0001)
    }
    # index
    center.push( index ) if @children.size % 2 != 0
    
    # indices > index
    (@children.size/2).times { 
      rights.push rand_range(index,right)
    }
    
    indices = [lefts,center,rights].flatten.sort
    
    indices.each_index { |i|
      left = nil
      left = indices[i-1] if i-1 >= 0
      right = nil
      right = indices[i+1] if i+1 < indices.size
      if i < @children.size/2.0 and i+1 > @children.size/2.0
        right = index
      end
      if i >= @children.size/2.0 and i-1 < @children.size/2.0
        left = index
      end
      
      @children.get(i).generate_indices(indices[i],left,right)
    }
  end
  
  # Compare two ParseNodes
  def ==(other)
    return false if not other.is_a? ParseNode
    other.keys.each { |key|
      if key != :is
        return false if other[key] != self[key]
      end
    }
    return true
  end
end
