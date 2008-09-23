require 'lib/method'
require 'lib/node'

module FDL

class NodeType < Method
  def build
    @@variables = []
    code = []
    
    expr = []
    expr.push "method_name = Kernel.this_method"
    expr.push "return @_nodes[method_name] if not @_nodes[method_name].nil?"
    super
    @expression = "#{expr.join("\n\t")}\n\t#{@expression}"
    
    code.push "# #{@tree.right}"
    
    return_vector = NodeType.collect(@tree.right).reject { |x| x.nil? or x == "" or x.empty? }
    if return_vector.size <= 0
      code.push "@_nodes[method_name] = ParseNodeSet.new"
    else
      code.push "# < #{return_vector.inspect} >"
      vars = return_vector.dup
      pnsets = (return_vector.map { |node| 
        node = node[0].gsub("\"","") if node.is_a? Array
        "_variables[\"#{node}\"]" 
      })
      
      code.push "@_nodes[method_name] = ParseNodeSet.new"
      vars.each_with_index { |var,i|
        code.push "@_nodes[method_name].concat(_universal.include?('#{var}') ? #{pnsets[i]} : #{pnsets[i]}.set[0])"
      }
    end
    code.push "return @_nodes[method_name]"
    
    @expression.gsub!("return false","return ParseNodeSet.new()")
    @return_vector = code.join("\n\t")
  end
  
  def NodeType.collect(node)
    rvector = []
    if node.nil?
      ;
    elsif node.type == "STRING"
      rvector.push "#{node.string}"
      rvector.concat NodeType.collect(node.left) if not node.left.nil?
    elsif node.type == "RVECTOR"
      rvector.concat NodeType.collect(node.left)
    end
    return rvector
  end
end

end
