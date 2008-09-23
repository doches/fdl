module FDL

# Generates a Ruby method for an FDL feature or node. The resulting code needs 
# to be attached to a FeatureExtractor in order to have the proper environment:
# i.e. @parsetree (the root of the parse tree as a lib/parsenode) and @env
# (a hashmap of pre-defined variables, including SELF,ROOT,and TARGET).
class Method
  attr_accessor :type,:declare,:header,:expression,:return_vector,:footer
  attr_reader :name
  
  def initialize(tree)
    @tree = tree
    @type = tree.type.downcase
    
    @@temp_count = 0
    @@res_count = 0
    @@localcount = 0
    @@in_negation = false
    
    self.build
  end
  
  def build
    @declare = "def #{@type}_#{@tree.string}"
    @name = "#{@type}_#{@tree.string}"
    
    # pre-declare variables and such
    @header = "_variables = Hash.new { |hash,key| hash[key] = self.send(\"node_\#{key}\".to_sym) }\n\t_universal = []"
    
    # code to match the expression
    # @expression = "begin\n\t\t#{Method.generate_expression(@tree.left)}\n\t\treturn false if (not _expr_result.is_true?)\n\trescue\n\t\treturn false\n\tend" # Rescue block.
    @expression = "_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })\n"
    t_code = []
    local = Method.get_localholder(t_code)
    @expression += "\t#{t_code.join("\n\t")}\n"
    @expression += "\t#{Method.generate_expression(@tree.left)}\n\treturn false if (not _expr_result)\n\n"
    # Replace negative ParseNodeSets with [] - set
    @expression += "\t_variables.each { |var,pnset|\n\t\tif pnset.negative?\n\t\t\t_t_all = _all.dup\n\t\t\t_t_all.concat(pnset)\n\t\t\t_variables[var] = _t_all\n\t\tend\n\t}"
    
    # code to generate the return vector
    @return_vector = "#return_vector"
    
    @footer = "end"
  end
  
  def to_s
    return "#{@declare}\n\t#{@header}\n\t\n\t#{@expression}\n\t\n\t#{@return_vector}\n#{footer}\n"
  end
  
  def Method.get_temp_variable
    var = "_var#{@@temp_count}"
    @@temp_count += 1
    return var
  end
  
  def Method.get_last_assigned_variable
    return "_var#{@@temp_count-1}"
  end
  
  def Method.get_temp_result
    var = "_result#{@@res_count}"
    @@res_count += 1
    return var
  end
  
  def Method.get_last_result
    return "_result#{@@res_count-1}"
  end
  
  def Method.get_localholder(code)
    @@localcount += 1
    var = "_local#{@@localcount}"
    code.push "#{var} = Hash.new { |hash,key| hash[key] = self.send(\"node_\#{key}\".to_sym) }"
    return var
  end
  
  def Method.localholder
    return "_local#{@@localcount}"
  end
  
  def Method.bind(var,pnset,localholder)
    code = []
    code.push "#{pnset}.negative=true" if @@in_negation
    code.push "#{localholder}['#{var}'] = #{pnset}"
    return code
  end
  
  # TODO OPTIMIZE ME
  def Method.resolve_negatives( local )
    code = <<RB
#{local}.each { |var,pnset|
  if pnset.negative?
    _t_all = _all.dup
    _t_all.concat(pnset)
    #{local}[var] = _t_all
  end
}
RB
    return code.split("\n")
  end
  
  def Method.inspect(var)
    str = "p #{var}.set.map {|x| x[:id]} \#{(#{var}.negative? ? '(-)' : '')}"
    begin
      true if @@first.nil?
    rescue NameError
      str = "puts\n#{str}"
      @@first = true
    end
    return str
  end
  
  def Method.generate_expression(node,local="_variables",extra_information=nil)
    code = []
    code.push "# BEGIN #{node}" if node.type != 'TRAVERSE' or extra_information == :first 
    local ||= Method.get_localholder(code)
    case node.type
      when "TRUE"
        code.push "_expr_result = true"
      when "FALSE"
        code.push "_expr_result = false"
      when "PREDICATE"
        code.push "_expr_result = Predicate::#{node.string}(#{local}.include?('#{node.left.string}') ? #{local}['#{node.left.string}'] : _variables['#{node.left.string}'])"
      when "AND"
        left_result = Method.get_temp_result
        left_local = Method.get_localholder(code)
        right_result = Method.get_temp_result
        right_local = Method.get_localholder(code)
        
        code.push Method.generate_expression(node.left,left_local)
        code.push "#{left_result} = _expr_result"
        
        code.concat Method.resolve_negatives( left_local )
        code.push "#{right_local} = #{left_local}.dup"
        code.push Method.generate_expression(node.right,right_local)
        code.push "#{right_result} = _expr_result"
        
        code.push "_expr_result = #{left_result} && #{right_result}"
        
        code.push "#{local} = HashSet.join_and(#{left_local},#{right_local})"
        code.push "_variables = HashSet.join_and(_variables,#{local})"
      when "OR"
        left_result = Method.get_temp_result
        left_local = Method.get_localholder(code)
        right_result = Method.get_temp_result
        right_local = Method.get_localholder(code)
        
        code.push Method.generate_expression(node.left,left_local)
        code.push "#{left_result} = _expr_result"
        
        code.concat Method.resolve_negatives( left_local )
        code.push "#{right_local} = #{left_local}.dup"
        code.push Method.generate_expression(node.right,right_local)
        code.push "#{right_result} = _expr_result"
        
        code.push "_expr_result = #{left_result} || #{right_result}"
        
        code.push "#{local} = HashSet.join_or(#{left_local},#{right_local})"
        code.push "_variables = HashSet.join_or(_variables,#{local})"
      when "NOT"
        @@in_negation = !@@in_negation
        negate_local = Method.get_localholder(code)
        code.push "#{negate_local} = #{local}.dup"
        code.push Method.generate_expression(node.left,negate_local)
#        code.push "#{local} = HashSet.join_and(#{local},#{negate_local})"
        # TODO: Replace with HashSet method
        code.push "#{negate_local}.each_pair { |var,pnset|"
        code.push "\tif #{local}.include?(var)"
        code.push "\t\t#{local}[var].concat(pnset)"
        code.push "\telse"
        code.push "\t\t#{local}[var] = pnset"
        code.push "\tend"
        code.push "}"
        code.push "_expr_result = !_expr_result"
        @@in_negation = !@@in_negation
      when "QUANTIFIER"
        code.push Method.generate_expression(node.left,local)
        code.push "_universal.push('#{node.string}') if not _universal.include?('#{node.string}')"
      when "EXPR"
        code.push "# BEGIN #{node.left} (EXPR)" if not node.left.type == "TRAVERSE"
        case node.left.type
          when "BIND"
            var = Method.get_temp_variable
            nodedesc = Method.generate_nodedesc_filter(node.left.left)
            if node.left.left.string != ''
              code.push "#{var} = (#{local}.include?('#{node.left.left.string}') ? #{local}['#{node.left.left.string}'] : _variables['#{node.left.left.string}'])"
            else
              code.push "#{var} = FDL::Extractor.match_node(@parsetree, #{nodedesc})"
            end
            code.push Method.bind(node.left.string,var,local)
            code.push "_expr_result = !#{var}.empty?"
          when "NODEDESC"
            var = Method.get_temp_variable
            nodedesc = Method.generate_nodedesc_filter(node.left)
            code.push "#{var} = FDL::Extractor.match_node(@parsetree, #{nodedesc})"
            code.push "_expr_result = !#{var}.empty?"
          when "TRAVERSE"
            code.push Method.generate_expression(node.left,local,:first)
            code.push "_expr_result = !#{Method.get_last_assigned_variable}.empty?"
        end
        code.push "# END   #{node.left} (EXPR)" if not node.left.type == "TRAVERSE"
      when "TRAVERSE"
        code.push "# BEGIN #{node.left} (TRAVERSE-L)"
        case node.left.type
          when "BIND"
            if extra_information == :first # Start
              var = Method.get_temp_variable
              if node.left.left.string != '' # Variable lookup
                code.push "#{var} = (#{local}.include?('#{node.left.string}') ? #{local}['#{node.left.string}'] : _variables['#{node.left.string}'])"
              else # search
                nodedesc = Method.generate_nodedesc_filter(node.left.left)
                code.push "#{var} = FDL::Extractor.match_node(@parsetree, #{nodedesc})"
                code.concat Method.bind(node.left.string,var,local)
              end
              code.push "_expr_result = !#{var}.empty?"
            else # Traverse from previous
              prev = Method.get_last_assigned_variable
              var = Method.get_temp_variable
              nodedesc = Method.generate_nodedesc_filter(node.left.left)
              p nodedesc
              operator = node.string
              operator = "\\\\" if operator == "\\"
              code.push "#{var} = #{prev}.traverse(\"#{operator}\",#{nodedesc},#{@@in_negation})"
              code.concat Method.bind(node.left.string,var,local)
              code.push "_expr_result = !#{var}.empty?"
            end
          when "NODEDESC"
            if extra_information == :first # Start
              var = Method.get_temp_variable
              if node.left.string != '' # Variable lookup
                code.push "#{var} = #{local}['#{node.left.string}']"
                code.push "#{var} ||= _variables['#{node.left.string}']"
              else # search
                nodedesc = Method.generate_nodedesc_filter(node.left)
                code.push "#{var} = FDL::Extractor.match_node(@parsetree, #{nodedesc})"
              end
              code.push "_expr_result = !#{var}.empty?"
            else # Traverse from previous
              prev = Method.get_last_assigned_variable
              var = Method.get_temp_variable
              nodedesc = Method.generate_nodedesc_filter(node.left)
              operator = node.string
              operator = "\\\\" if operator == "\\"
              code.push "#{var} = #{prev}.traverse(\"#{operator}\",#{nodedesc},#{@@in_negation})"
              code.push "#{local}['#{node.right.string}'].set.reject! { |node| not #{var}.include?(node) } if #{local}.include?('#{node.right.string}')" if node.right.string != ''
              code.push "_expr_result = !#{var}.empty?"
            end
        end
        code.push "# END   #{node.left} (TRAVERSE-L)"
        code.push "# BEGIN #{node.right} (TRAVERSE-R)"
        case node.right.type
          when "BIND"
            prev = Method.get_last_assigned_variable
            var = Method.get_temp_variable
            nodedesc = Method.generate_nodedesc_filter(node.right.left)
            operator = node.string
            operator = "\\\\" if operator == "\\"
            code.push "#{var} = #{prev}.traverse(\"#{operator}\",#{nodedesc},#{@@in_negation})"
            code.concat Method.bind(node.right.string,var,local)
            code.push "_expr_result = !#{var}.empty?"
          when "NODEDESC"
            prev = Method.get_last_assigned_variable
            var = Method.get_temp_variable
            nodedesc = Method.generate_nodedesc_filter(node.right)
            operator = node.string
            operator = "\\\\" if operator == "\\"
            code.push "#{var} = #{prev}.traverse(\"#{operator}\",#{nodedesc},#{@@in_negation})"
            code.push "#{local}['#{node.right.string}'].set.reject! { |node| not #{var}.include?(node) }" if node.right.string != ''
            code.push "_expr_result = !#{var}.empty?"
            code.push "#UPDATE#" if node.right.string != ''
          when "TRAVERSE"
            code.push Method.generate_expression(node.right)
        end
        code.push "# END   #{node.right} (TRAVERSE-R)"
    end
    code.push "# END   #{node}" if node.type != 'TRAVERSE' or extra_information == :first 
    return code.join("\n\t")
  end
  
  def Method.generate_nodedesc_filter(nodedesc)
    if nodedesc.left.nil?
      if nodedesc.string == ""
        return "proc { |node| not node.nil? }"
      else
        return "proc { |node| (not #{Method.localholder}[\"#{nodedesc.string}\"].nil? and #{Method.localholder}[\"#{nodedesc.string}\"].include?(node)) or (not _variables[\"#{nodedesc.string}\"].nil? and _variables[\"#{nodedesc.string}\"].include?(node)) }"
      end
    elsif nodedesc.left.type == "EQUALS" or nodedesc.left.type == "NOTEQUALS"
      comp = Method.format_comparator(nodedesc.left)
      return "proc { |node| (#{comp}) }"
    else
      return "proc { |node| #{Method.generate_nodedesc_filter_2(nodedesc.left)} }"
    end
  end
  
  def Method.generate_nodedesc_filter_2(nodedesc)
    case nodedesc.type
      when "AND"
        return "(#{Method.generate_nodedesc_filter_2(nodedesc.left)} and #{Method.generate_nodedesc_filter_2(nodedesc.right)})"
      when "OR"
        return "(#{Method.generate_nodedesc_filter_2(nodedesc.left)} or #{Method.generate_nodedesc_filter_2(nodedesc.right)})"
      else
        return "(#{Method.format_comparator(nodedesc)})"
    end
  end
  
  def Method.format_comparator(node)
    relation = node.type == "EQUALS" ? "==" : "!="
    lhs = ""
    
    # Interesting. Why do we sometimes get a nil NODEDESC?
    if node.right.nil?
      return "not node.nil?"
    end
    rhs = node.right.string
    case node.right.type
      when "STRING":
        lhs = "node[:#{node.left.string.to_sym}]"
        if ["self","target","root"].include?(rhs)
          lhs = "node[:is]"
          rhs = "#{relation} @_#{rhs}"
        elsif ["nil","null"].include?(rhs.downcase)
          lhs += ".nil?"
          lhs = "not #{lhs}" if relation == "!="
          rhs = ""
        else
          rhs = "#{relation} (#{Method.localholder}['#{rhs}'].nil? ? _variables['#{rhs}'] : #{Method.localholder}['#{rhs}'])"
        end
      when "REGEX":
        relation = (relation == "==" ? "" : "not ")
        lhs = "#{relation}node[:#{node.left.string.to_sym}]"
        rhs = "=~ /#{rhs[1..rhs.size-2]}/"
      when "QSTRING":
        lhs = "node[:#{node.left.string.to_sym}]"
        rhs = "#{relation} \"#{rhs}\""
    end
    return "#{lhs} #{rhs}"
  end
  
end # End Class

end # End Module
