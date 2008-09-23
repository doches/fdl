require 'lib/extractor'

# Make this less dumb.
# Damn, this is dumb.
def rand_range(min,max)
  x = min+rand
  while not (x >= min and x <= max)
    x = (rand * (max - min + 1)) + min
  end
  return x
end

class ParseNode < Hash
  attr_accessor :children,:parent
  
  def initialize
    super
    
    @children = []
    self[:is] = self
  end
  
  
  def print_tree(level=0,key=:id)
#    key = :index
    level.times{print "  "}
    print "[#{self[:id]} -> "
    print (@children.map { |x| "#{x[key]}"}).join(", ")
    print "]\n"
    @children.each {|c| c.print_tree(level+1,key) }
  end
  
  def print_set(keys=[:id])
    [self, self.collect_children].flatten.each { |c|
      print "[", (keys.map { |key| "#{key}=#{c[key]}" }).join(", "),"]\n"
    }
  end
  
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
      
      @children[i].generate_indices(indices[i],left,right)
    }
  end

  def collect_children
    nodes = @children.dup
    @children.each { |child|
      nodes.concat(child.collect_children)
    }
    return nodes
  end
  
  def ==(other)
    return false if not other.is_a? ParseNode
    other.keys.each { |key|
      if key != :is
        return false if other[key] != self[key]
      end
    }
    return true
  end
  
  def traverse(operator,match)
    ParseNodeSet.new(self).traverse(operator,match)
  end
end 

class ParseNodeSet
  attr_accessor :universal,:set
  def initialize(set=[])
    set = set.set if set.is_a? ParseNodeSet
    set = [set] if set.is_a? ParseNode
    @set = set
    @set = ParseNodeSet.hashify(@set) if @set.is_a? Array
    @universal = false
  end
  
  def ==(other)
    return false if not other.is_a? ParseNodeSet
    
    return false if not other.size == self.size
    
    @set.each { |node|
      return false if not other.set.include? node
    }
    return true
  end
  
  def ParseNodeSet.tree=(parsetree)
    @@root = parsetree
    @@nodes = @@root.collect_children.push @@root
  end
  
  def to_s
    "<"+@set.join(", ")+">"
  end
  
  def size
    @set.size
  end
  
  def push(o)
    @set.push o
  end
  
  def get(i)
    @set[i]
  end
  
  def each(&p)
    @set.each{|x| p.call(x) }
  end
  
  def reject!(&p)
    @set.reject! {|x| p.call(x) }
  end

  def concat(r)
    if r.is_a?(Array)
      @set.concat(r)
    elsif r.is_a?(ParseNodeSet)
      r.each { |x| @set.push x }
    elsif r.is_a?(ParseNode)
      @set.push r
    end
  end
  
  def include?(node)
    @set.include?(node)
  end
  
  def [](key)
    if key == :size
      return self.size
    else
      if self.universal
        return @set.map { |x| x[key] }
      elsif not empty?
        return @set[0][key]
      else
        return false
      end
    end
  end
  
  def empty?
    @set.empty?
  end
=begin  
  def method_missing(m, *args)
    @set[0].send(m, *args)
  end
=end  
  def children
    s = ParseNodeSet.new
    @set.each { |k,i| s.concat(i.children) if not i.nil? }
    s.reject! { |x| x.nil? }
    return s
  end
  
  def parent
    s = ParseNodeSet.new
    @set.each { |k,i| s.push(i.parent) if not i.nil? }
    s.reject! { |x| x.nil? }
    return s
  end
  
  def traverse(operator,match)
    set = {}
    case operator
      when "/"
        @set.each { |node|
          set[node] = node.parent if not node.nil? and not node.parent.nil?
          set[node] = ParseNodeSet.new(set[node]) if not set[node].is_a? ParseNodeSet
        }
      when "\\"
        @set.each { |node|
          set[node] = node.children if not node.nil? and not node.children.nil?
          set[node] = ParseNodeSet.new(set[node]) if not set[node].is_a? ParseNodeSet
        }
      when "/*"
        @set.each { |node|
          nset = ParseNodeSet.new([node])
          n = node
          while not n.nil? and not n.empty?
            nset.concat(n.parent)
            n = n.parent
          end
          set[node] = nset
        }
      when "\*"
        @set.each { |node|
          nset = ParseNodeSet.new([node])
          n = ParseNodeSet.new([node])
          while not n.nil? and not n.empty?
            tnode = n.set.pop
            nset.concat(tnode.children) #BUGGERED
            n.concat(tnode.children)
          end
          set[node] = nset
#          print node[:id],": ",nset[:id],"\n"
        }
    end
    set.reject! { |k,nodeset| not match.call(nodeset) } if not set.empty?
    
    newset = ParseNodeSet.new
    result = ParseNodeSet.new
    set.each { |keynode,nodeset|
      newset.concat(keynode)
      result.concat(nodeset)
    }
    @set = (@set & newset.set)
    @set = ParseNodeSet.hashify(@set) if @set.is_a? Array
    return result
  end
  
  def ParseNodeSet.hashify(array)
    set = {}
    array.each { |node| set[node[:id]] = node }
    return set
  end
        
  def traverse2(operator,match)
    set = ParseNodeSet.new
    case operator
      when "/"
        set = self.parent
      when "\\"
        set = self.children
      when "/*"
        set.concat(self)
        n = self
        while not n.nil? and not n.empty?
          set.concat(n.parent)
          n = n.parent
        end
      when "\*"
        set.concat(self)
        n = self
        while not n.nil? and not n.empty?
          set.concat(n.children)
          n = n.children
        end
      when "|"
        set = self.parent.children
      when "<|"
        siblings = self.parent.children
        for i in 0..(siblings.size-1)
          break if siblings.get(i) == self
          set.push siblings.get(i)
        end
      when ">|"
        siblings = self.parent.children
        for i in 0..(siblings.size-1)
          index = siblings.size-1-i
          break if siblings.get(i) == self
          set.push siblings.get(i)
        end
      when ">*"
        @@nodes.each { |node| set.push(node) if node[:index] >= self[:index] }
      when "<*"
        @@nodes.each { |node| set.push(node) if node[:index] <= self[:index] }
    end
    set.reject! { |node| not match.call(node) } if not set.empty?
    return set
  end

#  def inspect(key=:id)
#    return "[",(@set.map { |node| "#{node[key]}" }).sort.join(", "),"]"
#  end
    
end
