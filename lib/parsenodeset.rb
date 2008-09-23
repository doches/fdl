# A ParseNodeSet contains zero or more ParseNode objects, and can be treated in
# the same way as an individual ParseNode. 
class ParseNodeSet
  # :universal - Expand this set inside a return vector?
  # :set - An array containing the nodes within this set
  attr_accessor :universal, :set
  attr_writer :negative
  
  # Set global parse tree (an XMLSentence), for left-of/right-of lookup.
  def ParseNodeSet.tree=(parsetree)
    @@root = parsetree
    if parsetree.respond_to? :traverse
      @@nodes = parsetree.traverse("\*",proc { |node| not node.nil? })
    else
      @@nodes = parsetree.root.traverse("\*",proc { |node| not node.nil? })
    end
    
    @negative = false
  end

  def negative?
    @negative
  end
  
  # Create a new ParseNodeSet from:
  # * array of ParseNodes
  # * individual ParseNode
  # * ParseNodeSet
  def initialize(set=[])
    if set.is_a? Array
      @set = set.dup
    elsif set.is_a? ParseNode
      @set = [set.dup]
    elsif set.is_a? ParseNodeSet
      @set = set.set.dup
    elsif set.nil?
      @set = []
    else
      raise "Cannot initialize ParseNodeSet with object of type #{set.class}\n\t#{set}\n"
    end
    
    self.negative = false
    self.universal = false
  end
  
  # Two ParseNodeSets are equal if they contain exactly the same ParseNodes.
  def ==(other)
    return false if not other.is_a? ParseNodeSet
    return false if not other.size == self.size
    
    @set.each { |id| 
      return false if not other.include? id
    }
    return true
  end
  
  # Returns the number of nodes contained by this ParseNodeSet
  def size
    @set.size
  end
  
  # Add a new node to the set
  def push(node)
    @set.push node
  end
  
  # Retrieve a specific node from the set.
  def get(i)
    @set[i]
  end
  
  # Iterate over this ParseNodeSet
  def each(&p)
    @set.each { |node| p.call(node) }
  end
  
  # Reject nodes matching the provided block
  def reject(&p)
    ParseNodeSet.new(@set.reject { |n| p.call(n) })
  end
  
  # Reject nodes matching the provided block
  def reject!(&p)
    @set.reject! { |node| p.call(node) }
  end
  
  # Determine whether two parsenodesets contain any overlapping nodes
  def overlap?(pnset)
    throw "Cannot test overlap between ParseNodeSet and variable of type #{pnset.class} ('#{pnset.to_sym}')" if not pnset.is_a? ParseNodeSet
    @set.each { |pnode|
      return true if pnset.include?(pnode)
    }
    return false
  end
  
  # Add a new ParseNode, an array of ParseNodes, or a ParseNodeSet to this nodeset
  def concat(thing)
    if thing.is_a? Array
      thing.each { |thing|
        @set.concat thing if not @set.include?(thing)
      }
    elsif thing.is_a? ParseNode
      @set.push thing if not @set.include?(thing)
    elsif thing.is_a? ParseNodeSet
      if thing.negative? and not self.negative?
        @set.reject! { |pnode|
          thing.include?(pnode)
        }
      else
        thing.set.each { |pnode|
          @set.push pnode if not @set.include?(pnode)
        }
      end
    elsif thing.nil?
      @set
    else
      raise "Cannot concatenate ParseNodeSet with object of type #{thing.class}\n\t#{thing}\n"
    end
  end
  
  # Does this ParseNodeSet include a particular ParseNode?
  def include?(node)
    @set.include?(node)
  end
  
  # Treat a ParseNodeSet like a hash to retrieve properties of nodes within.
  # If @universal is true, return an array of properties.
  # 
  # Special keys:
  # :size returns the size of this ParseNodeSet
  def [](key)
    return self.size if key == :size
    
    if @universal
      # Return an array containing the requested property for each node in this
      # set.
      return @set.map { |node| node[key] }
    elsif not empty?
      # Return the requested property from the first node added to this  set
      return @set[0][key]
    else
      # This is an empty set, so it has no properties
      return false
    end
  end
  
  # Is this set empty?
  def empty?
    @set.empty?
  end
  
  # Get a ParseNodeSet containing all of the children of the nodes within this
  # set.
  def children
    children = ParseNodeSet.new
    @set.each { |node| children.concat(node.children) }
    return children
  end
  
  # Get a ParseNodeSet containing the parent(s) of the nodes within this set.
  def parent
    parent = ParseNodeSet.new
    @set.each { |node| parent.push(node.parent) }
    return children
  end
  
  # Pop an element from the front of this ParseNodeSet.
  def pop
    @set.pop
  end
  
  # Get the nodes on the specified traversal path that match the given block.
  def traverse(operator,match,negate=false)
    map = {}
    # Build a map between nodes within the set and what they traverse to.
    case operator
      when "/"
        @set.each { |node|
          map[node] = ParseNodeSet.new(node.parent) if not node.parent.nil?
        }
      when "\\"
        @set.each { |node|
          map[node] = ParseNodeSet.new(node.children) if not node.children.nil?
        }
      when "/*"
        @set.each { |node|
          # Build 'node_set' up with elements to return
          node_set = ParseNodeSet.new(node)
          # Maintain 'path_set' up with node to traverse
          path_set = node
          while not path_set.nil? and not path_set.empty?
            node_set.concat(path_set.parent) if not path_set.parent.nil?
            path_set = path_set.parent
          end
          map[node] = node_set
        }
      when "\*"
        @set.each { |node|
          # Build 'node_set' up with elements to return
          node_set = ParseNodeSet.new(node)
          # Maintain 'path_set' up with node to traverse
          path_set = ParseNodeSet.new(node)
          while not path_set.nil? and not path_set.empty?
            traverse_node = path_set.pop
            if not traverse_node.children.nil? and not traverse_node.children.empty?
              node_set.concat(traverse_node.children)
              path_set.concat(traverse_node.children)
            end
          end
          map[node] = node_set
        }
      when "|"
        @set.each { |node|
          map[node] = ParseNodeSet.new( (node.parent.nil? ? node : node.parent.children) )
        }
      when "<|"
        @set.each { |node|
          if not node.parent.nil?
            node_set = ParseNodeSet.new
            siblings = node.parent.children
            for i in 0...(siblings.size)
              break if siblings.get(i) == node
              node_set.push siblings.get(i)
            end
            map[node] = node_set
          end
        }
      when ">|"
        @set.each { |node|
          if not node.parent.nil?
            node_set = ParseNodeSet.new
            siblings = node.parent.children
            for i in 0...(siblings.size)
              index = siblings.size-1-i
              break if siblings.get(index) == node
              node_set.push siblings.get(index)
            end
            map[node] = node_set
          end
        }
      when ">*"
        @set.each { |node|
          node_set = ParseNodeSet.new
          # Comparison between nodes uses index for <=>
          @@nodes.each { |n| node_set.push(n) if n >= node }
          map[node] = node_set
        }
      when "<*"
        @set.each { |node|
          node_set = ParseNodeSet.new
          # Comparison between nodes uses index for <=>
          @@nodes.each { |n| node_set.push(n) if n <= node }
          map[node] = node_set
        }
      when ">>"
        @set.each { |node|
          node_set = ParseNodeSet.new
          # Comparison between nodes uses index for <=>
          @@nodes.each { |n| node_set.push(n) if n > node }
          map[node] = node_set
        }
      when "<<"
        @set.each { |node|
          node_set = ParseNodeSet.new
          # Comparison between nodes uses index for <=>
          @@nodes.each { |n| node_set.push(n) if n < node }
          map[node] = node_set
        }
      when "cc"
        @set.each { |node|
          node_set = ParseNodeSet.new
          siblings = node.traverse("|",match).reject { |n| n == node }
          node_set.concat siblings.traverse("\*",match)
          map[node] = node_set 
        }
      else
        raise "Unknown traversal operator '#{operator}'"
    end
    # Reject non-matching nodes
    map.each_key { |keynode|
      map[keynode].reject! { |node| not match.call(node) }
    }
    # Print trimmed results
#    map.each_key { |key| print "#{key[:id]}:\t[", (map[key].set.map { |node| node[:id] }).join(", "), "]\n" }

    # Build (simultaneously) an array of results and a new array for this node,
    # in case it is bound to a variable and needs to be updated.
    new_set = []
    results = ParseNodeSet.new
    map.each_key { |keynode|
      if not map[keynode].nil? and not map[keynode].empty?
        new_set.push keynode
        results.concat(map[keynode])
      end
    }
    if not negate
      @set = new_set
    else
      @set -= new_set
    end
    return results
  end
  
  def uniq!
    @set.uniq!
  end
end
