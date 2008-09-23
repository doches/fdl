require 'lib/parsenode'

module FDL

# Contains utility methods called by generated feature extractors.
class Extractor
  # Implements a depth-first, leftmost search for nodes that matches &match
  def Extractor.match_node(parsetree,match)
    matches = ParseNodeSet.new
    return false if parsetree.nil?

    matches.push(parsetree) if match.call(parsetree)

    parsetree.children.each { |child|
      more_matches = Extractor.match_node(child,match)
      matches.concat( more_matches )
    }
    return matches
  end
  
  # Useful for debugging
  def Extractor.print_match_node(parsetree,match,indent=0)
    return false if parsetree.nil?
    
    p parsetree if match.call(parsetree)
    
    parsetree.children.each { |child| 
      Extractor.print_match_node(child,match,indent+1)
    }
  end
  
  # Useful for debugging
  def Extractor.print_tree(tree,indent=0)
    indent.times { print "  " }
    p tree
    
    tree.children.each { |child| Extractor.print_tree(child,indent+1) }
  end
end

end
