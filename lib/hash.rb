require 'lib/parsenodeset'

class HashSet
  # Return the union of two Hashes, defined as:
  # 
  # If A,B are hashes where each key is a variable name and each value is a ParseNodeSet,
  # x is a variable name (key) in HashSet.union(A,B) iff x is a variable name (key) in either
  # A or B.
  # 
  # The value of x is the ParseNodeSet A[x] union B[x]
  def HashSet.union(a,b)
    final = {}
    a.each { |var,pnset| final[var] = ParseNodeSet.new(pnset) }
    b.each { |var,pnset| (final.include?(var) ? final[var].concat(pnset) : final[var] = pnset) }
    final.each { |key,value| value.uniq! }
    return final
  end
  
  # Return the intersection of two Hashes, defined as:
  #
  # If A,B are Hashes where each key is a variable name and each value is a ParseNodeSet,
  # x is a variable name (key) in HashSet.intersection(A,B) iff x is a variable name (key) in 
  # both A an B.
  #
  # HashSet.intersection(A,B)[x] is A[x] intersection B[x]
  def HashSet.intersection(a,b)
    union = (a.keys + b.keys).uniq
    keys = union - (union - a.keys) - (union - b.keys)
    final = {}
    keys.each { |var| 
      set = ParseNodeSet.new
      a[var].each { |i| set.push(i) if b[var].include?(i) }
      b[var].each { |i| set.push(i) if a[var].include?(i) and not set.include?(i) }
      final[var] = set
    }
    return final
  end
  
  # Return something inbetween. For hashes A,B, join_and returns a hash containing the union of
  # A.keys, B.keys, with each key pointing to the intersection of A[key] B[key]. TODO: optimize. (Hash.each_pair ?)
  def HashSet.join_and(a,b)
    final = {}
    negative = {}
    a.each { |var,pnset| 
      final[var] = ParseNodeSet.new(pnset)
      if(pnset.respond_to?(:negative?) and pnset.negative?)
        final[var].negative=true
        negative[var] = true
      end
    }
    b.each { |var,pnset| 
      (final[var].nil? ? final[var] = ParseNodeSet.new(pnset) : final[var].concat(pnset))
      negative[var] = true if pnset.negative?
    }
    final.each { |key,value| value.uniq! }
    
    # Intersection of ParseNodeSets
    final.each { |key,value|
      if a.include?(key) and b.include?(key) and not negative[key] # If this variable is in both sets...
        final[key] = ParseNodeSet.new(value.set - (value.set - a[key].set) - (value.set - b[key].set))
      end
    }
    
    return final
  end
  
  def HashSet.join_or(a,b)
    final = {}
    a.each { |var,pnset|
      final[var] = pnset
    }
    b.each { |var,pnset| (final.include?(var) ? final[var].concat(pnset) : final[var] = pnset) }
    return final
  end
  
  # Remove elements in B from A
  def HashSet.delete(a,b)
    set = a.dup
    set.each_pair { |var,pnset| pnset.reject! { |pnode| b.include?(var) and b[var].include?(pnode) }}
    set.reject! { |var,pnset| pnset.nil? or pnset.empty? }
    return set
  end
end
