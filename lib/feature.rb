require 'lib/method'
require 'lib/node'

module FDL

class Feature < Method
  def build
    super
    
    @@variables = []
    code = []
    @return_vector = Feature.collect(@tree.right)
    if @return_vector.size <= 0
      code.push "return true"
    else
      code.push "_universal.each { |varname| _variables[varname].universal = true }"
      code.push "[#{(@@variables.map {|x| "\"#{x}\""}).join(', ')}].each { |v| return false if not _variables.include?(v) }"
      code.push "return [ #{@return_vector.join(', ')} ].flatten"
    end
    
    @return_vector = code.join("\n\t")
  end
  
  def Feature.collect(node)
    return_vector = []
    if node.nil?
      ;
    elsif node.type == "DOT" 
      @@variables.push node.left.string.gsub("\"","").gsub("\'","")
      return_vector.push "_variables[\"#{node.left.string}\"][:#{node.right.string.to_sym}]"
    elsif node.type == "STRING"
      return_vector.push "\"#{node.string}\""
    elsif node.type == "RVECTOR"
      return_vector.concat [Feature.collect(node.left), Feature.collect(node.right)]
    end
    return return_vector
  end
end

end
