require 'lib/extractor'
require 'lib/parsenode'
require 'lib/current_method'
require 'lib/hash'
require 'lib/predicate'

class FeatureExtractor
  attr_reader :features
  
  include FDL
  
	def initialize(parsetree,_self,root,target)
		@parsetree = parsetree
		@_self = _self
		@_root = root
		@_target = target
		
		@_nodes = {}
		
		ParseNodeSet.tree = parsetree
		@features = [:feature_matching2, :feature_matching1, :feature_list_ids, :feature_universal_size, :feature_is_equal, :feature_and_or, :feature_or_binding, :feature_noderef, :feature_negate, :feature_negate2, :feature_regex, :feature_not_rebind_and, :feature_update_parentof]
	end
	
	def featurize
	  return @features.map { |method| self.send(method.to_sym) }
	end
	
  def method_missing(sym)
    var = "#{sym}"
    var = var[var.index("_")+1..var.size] if var.index("_")
    feature = nil
    caller.each { |line|
      if line.include?("feature_")
        feature = line[line.index("feature_")+8..(line.size-1)]
        break
      end
    }
    raise "Missing method (probably due to unbound variable '#{var}') called in feature '#{feature}'"
  end

	def node_leaves
		_variables = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_universal = []
		
		method_name = Kernel.this_method
		return @_nodes[method_name] if not @_nodes[method_name].nil?
		_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })
		_local1 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN   QUANTIFIER:[x]
		# BEGIN     EXPR:[]
		# BEGIN       BIND:[x] (EXPR)
		_var0 = FDL::Extractor.match_node(@parsetree, proc { |node| (not node[:word].nil? ) })
		_variables['x'] = _var0
		_expr_result = !_var0.empty?
		# END         BIND:[x] (EXPR)
		# END       EXPR:[]
		_universal.push('x') if not _universal.include?('x')
		# END     QUANTIFIER:[x]
		return ParseNodeSet.new() if (not _expr_result)
	
		_variables.each { |var,pnset|
			if pnset.negative?
				_t_all = _all.dup
				_t_all.concat(pnset)
				_variables[var] = _t_all
			end
		}
		
		#   RVECTOR:[]
		# < ["x"] >
		@_nodes[method_name] = ParseNodeSet.new
		@_nodes[method_name].concat(_universal.include?('x') ? _variables["x"] : _variables["x"].set[0])
		return @_nodes[method_name]
	end
	
	def feature_matching2
		_variables = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_universal = []
		
		_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })
		_local1 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN   EXPR:[]
		# BEGIN     TRAVERSE:[/]
		# BEGIN       NODEDESC:[] (TRAVERSE-L)
		_var0 = FDL::Extractor.match_node(@parsetree, proc { |node| (node[:is] == @_root) })
		_expr_result = !_var0.empty?
		# END         NODEDESC:[] (TRAVERSE-L)
		# BEGIN       NODEDESC:[] (TRAVERSE-R)
		_var1 = _var0.traverse("/",proc { |node| not node.nil? },false)
		_expr_result = !_var1.empty?
		# END         NODEDESC:[] (TRAVERSE-R)
		# END       TRAVERSE:[/]
		_expr_result = !_var1.empty?
		# END     EXPR:[]
		return false if (not _expr_result)
	
		_variables.each { |var,pnset|
			if pnset.negative?
				_t_all = _all.dup
				_t_all.concat(pnset)
				_variables[var] = _t_all
			end
		}
		
		return true
	end
	
	def feature_matching1
		_variables = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_universal = []
		
		_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })
		_local1 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN   EXPR:[]
		# BEGIN     TRAVERSE:[\]
		# BEGIN       NODEDESC:[] (TRAVERSE-L)
		_var0 = FDL::Extractor.match_node(@parsetree, proc { |node| (node[:is] == @_root) })
		_expr_result = !_var0.empty?
		# END         NODEDESC:[] (TRAVERSE-L)
		# BEGIN       NODEDESC:[] (TRAVERSE-R)
		_var1 = _var0.traverse("\\",proc { |node| not node.nil? },false)
		_expr_result = !_var1.empty?
		# END         NODEDESC:[] (TRAVERSE-R)
		# END       TRAVERSE:[\]
		_expr_result = !_var1.empty?
		# END     EXPR:[]
		return false if (not _expr_result)
	
		_variables.each { |var,pnset|
			if pnset.negative?
				_t_all = _all.dup
				_t_all.concat(pnset)
				_variables[var] = _t_all
			end
		}
		
		return true
	end
	
	def feature_list_ids
		_variables = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_universal = []
		
		_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })
		_local1 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN   QUANTIFIER:[x]
		# BEGIN     EXPR:[]
		# BEGIN       BIND:[x] (EXPR)
		_var0 = FDL::Extractor.match_node(@parsetree, proc { |node| (node[:word].nil? ) })
		_variables['x'] = _var0
		_expr_result = !_var0.empty?
		# END         BIND:[x] (EXPR)
		# END       EXPR:[]
		_universal.push('x') if not _universal.include?('x')
		# END     QUANTIFIER:[x]
		return false if (not _expr_result)
	
		_variables.each { |var,pnset|
			if pnset.negative?
				_t_all = _all.dup
				_t_all.concat(pnset)
				_variables[var] = _t_all
			end
		}
		
		_universal.each { |varname| _variables[varname].universal = true }
		["x"].each { |v| return false if not _variables.include?(v) }
		return [ _variables["x"][:id] ].flatten
	end
	
	def feature_universal_size
		_variables = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_universal = []
		
		_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })
		_local1 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN   QUANTIFIER:[x]
		# BEGIN     EXPR:[]
		# BEGIN       BIND:[x] (EXPR)
		_var0 = FDL::Extractor.match_node(@parsetree, proc { |node| (not node[:word].nil? ) })
		_variables['x'] = _var0
		_expr_result = !_var0.empty?
		# END         BIND:[x] (EXPR)
		# END       EXPR:[]
		_universal.push('x') if not _universal.include?('x')
		# END     QUANTIFIER:[x]
		return false if (not _expr_result)
	
		_variables.each { |var,pnset|
			if pnset.negative?
				_t_all = _all.dup
				_t_all.concat(pnset)
				_variables[var] = _t_all
			end
		}
		
		_universal.each { |varname| _variables[varname].universal = true }
		["x"].each { |v| return false if not _variables.include?(v) }
		return [ _variables["x"][:size] ].flatten
	end
	
	def feature_is_equal
		_variables = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_universal = []
		
		_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })
		_local1 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN   EXPR:[]
		# BEGIN     BIND:[x] (EXPR)
		_var0 = FDL::Extractor.match_node(@parsetree, proc { |node| (node[:is] == @_self) })
		_variables['x'] = _var0
		_expr_result = !_var0.empty?
		# END       BIND:[x] (EXPR)
		# END     EXPR:[]
		return false if (not _expr_result)
	
		_variables.each { |var,pnset|
			if pnset.negative?
				_t_all = _all.dup
				_t_all.concat(pnset)
				_variables[var] = _t_all
			end
		}
		
		_universal.each { |varname| _variables[varname].universal = true }
		["x"].each { |v| return false if not _variables.include?(v) }
		return [ _variables["x"][:id] ].flatten
	end
	
	def feature_and_or
		_variables = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_universal = []
		
		_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })
		_local1 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN   AND:[]
		_local2 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_local3 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN     QUANTIFIER:[x]
		# BEGIN       AND:[]
		_local4 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_local5 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN         EXPR:[]
		# BEGIN           BIND:[x] (EXPR)
		_var0 = FDL::Extractor.match_node(@parsetree, proc { |node| (node[:word].nil? ) })
		_local4['x'] = _var0
		_expr_result = !_var0.empty?
		# END             BIND:[x] (EXPR)
		# END           EXPR:[]
		_result2 = _expr_result
		_local4.each { |var,pnset|
		  if pnset.negative?
		    _t_all = _all.dup
		    _t_all.concat(pnset)
		    _local4[var] = _t_all
		  end
		}
		_local5 = _local4.dup
		# BEGIN         EXPR:[]
		# BEGIN           BIND:[x] (EXPR)
		_var1 = FDL::Extractor.match_node(@parsetree, proc { |node| (not node[:word].nil? ) })
		_local5['x'] = _var1
		_expr_result = !_var1.empty?
		# END             BIND:[x] (EXPR)
		# END           EXPR:[]
		_result3 = _expr_result
		_expr_result = _result2 && _result3
		_local2 = HashSet.join_and(_local4,_local5)
		_variables = HashSet.join_and(_variables,_local2)
		# END         AND:[]
		_universal.push('x') if not _universal.include?('x')
		# END       QUANTIFIER:[x]
		_result0 = _expr_result
		_local2.each { |var,pnset|
		  if pnset.negative?
		    _t_all = _all.dup
		    _t_all.concat(pnset)
		    _local2[var] = _t_all
		  end
		}
		_local3 = _local2.dup
		# BEGIN     QUANTIFIER:[y]
		# BEGIN       OR:[]
		_local6 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_local7 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN         EXPR:[]
		# BEGIN           BIND:[y] (EXPR)
		_var2 = FDL::Extractor.match_node(@parsetree, proc { |node| (node[:word].nil? ) })
		_local6['y'] = _var2
		_expr_result = !_var2.empty?
		# END             BIND:[y] (EXPR)
		# END           EXPR:[]
		_result4 = _expr_result
		_local6.each { |var,pnset|
		  if pnset.negative?
		    _t_all = _all.dup
		    _t_all.concat(pnset)
		    _local6[var] = _t_all
		  end
		}
		_local7 = _local6.dup
		# BEGIN         EXPR:[]
		# BEGIN           BIND:[y] (EXPR)
		_var3 = FDL::Extractor.match_node(@parsetree, proc { |node| (not node[:word].nil? ) })
		_local7['y'] = _var3
		_expr_result = !_var3.empty?
		# END             BIND:[y] (EXPR)
		# END           EXPR:[]
		_result5 = _expr_result
		_expr_result = _result4 || _result5
		_local3 = HashSet.join_or(_local6,_local7)
		_variables = HashSet.join_or(_variables,_local3)
		# END         OR:[]
		_universal.push('y') if not _universal.include?('y')
		# END       QUANTIFIER:[y]
		_result1 = _expr_result
		_expr_result = _result0 && _result1
		_variables = HashSet.join_and(_local2,_local3)
		_variables = HashSet.join_and(_variables,_variables)
		# END     AND:[]
		return false if (not _expr_result)
	
		_variables.each { |var,pnset|
			if pnset.negative?
				_t_all = _all.dup
				_t_all.concat(pnset)
				_variables[var] = _t_all
			end
		}
		
		_universal.each { |varname| _variables[varname].universal = true }
		["x", "y"].each { |v| return false if not _variables.include?(v) }
		return [ _variables["x"][:size], _variables["y"][:size] ].flatten
	end
	
	def feature_or_binding
		_variables = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_universal = []
		
		_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })
		_local1 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN   QUANTIFIER:[x]
		# BEGIN     OR:[]
		_local2 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_local3 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN       EXPR:[]
		# BEGIN         TRAVERSE:[/]
		# BEGIN           BIND:[x] (TRAVERSE-L)
		_var0 = FDL::Extractor.match_node(@parsetree, proc { |node| not node.nil? })
		_local2['x'] = _var0
		_expr_result = !_var0.empty?
		# END             BIND:[x] (TRAVERSE-L)
		# BEGIN           NODEDESC:[] (TRAVERSE-R)
		_var1 = _var0.traverse("/",proc { |node| (node[:id] == "pie._0_502") },false)
		_expr_result = !_var1.empty?
		# END             NODEDESC:[] (TRAVERSE-R)
		# END           TRAVERSE:[/]
		_expr_result = !_var1.empty?
		# END         EXPR:[]
		_result0 = _expr_result
		_local2.each { |var,pnset|
		  if pnset.negative?
		    _t_all = _all.dup
		    _t_all.concat(pnset)
		    _local2[var] = _t_all
		  end
		}
		_local3 = _local2.dup
		# BEGIN       EXPR:[]
		# BEGIN         BIND:[x] (EXPR)
		_var2 = FDL::Extractor.match_node(@parsetree, proc { |node| (not node[:word].nil? ) })
		_local3['x'] = _var2
		_expr_result = !_var2.empty?
		# END           BIND:[x] (EXPR)
		# END         EXPR:[]
		_result1 = _expr_result
		_expr_result = _result0 || _result1
		_variables = HashSet.join_or(_local2,_local3)
		_variables = HashSet.join_or(_variables,_variables)
		# END       OR:[]
		_universal.push('x') if not _universal.include?('x')
		# END     QUANTIFIER:[x]
		return false if (not _expr_result)
	
		_variables.each { |var,pnset|
			if pnset.negative?
				_t_all = _all.dup
				_t_all.concat(pnset)
				_variables[var] = _t_all
			end
		}
		
		_universal.each { |varname| _variables[varname].universal = true }
		["x"].each { |v| return false if not _variables.include?(v) }
		return [ _variables["x"][:size] ].flatten
	end
	
	def feature_noderef
		_variables = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_universal = []
		
		_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })
		_local1 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN   QUANTIFIER:[x]
		# BEGIN     EXPR:[]
		# BEGIN       TRAVERSE:[\]
		# BEGIN         BIND:[x] (TRAVERSE-L)
		_var0 = FDL::Extractor.match_node(@parsetree, proc { |node| not node.nil? })
		_variables['x'] = _var0
		_expr_result = !_var0.empty?
		# END           BIND:[x] (TRAVERSE-L)
		# BEGIN         NODEDESC:[leaves] (TRAVERSE-R)
		_var1 = _var0.traverse("\\",proc { |node| (not _local1["leaves"].nil? and _local1["leaves"].include?(node)) or (not _variables["leaves"].nil? and _variables["leaves"].include?(node)) },false)
		_variables['leaves'].set.reject! { |node| not _var1.include?(node) }
		_expr_result = !_var1.empty?
		#UPDATE#
		# END           NODEDESC:[leaves] (TRAVERSE-R)
		# END         TRAVERSE:[\]
		_expr_result = !_var1.empty?
		# END       EXPR:[]
		_universal.push('x') if not _universal.include?('x')
		# END     QUANTIFIER:[x]
		return false if (not _expr_result)
	
		_variables.each { |var,pnset|
			if pnset.negative?
				_t_all = _all.dup
				_t_all.concat(pnset)
				_variables[var] = _t_all
			end
		}
		
		_universal.each { |varname| _variables[varname].universal = true }
		["x"].each { |v| return false if not _variables.include?(v) }
		return [ _variables["x"][:size] ].flatten
	end
	
	def feature_negate
		_variables = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_universal = []
		
		_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })
		_local1 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN   NOT:[]
		_local2 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_local2 = _variables.dup
		# BEGIN     EXPR:[]
		# BEGIN       TRAVERSE:[\]
		# BEGIN         NODEDESC:[] (TRAVERSE-L)
		_var0 = FDL::Extractor.match_node(@parsetree, proc { |node| not node.nil? })
		_expr_result = !_var0.empty?
		# END           NODEDESC:[] (TRAVERSE-L)
		# BEGIN         NODEDESC:[] (TRAVERSE-R)
		_var1 = _var0.traverse("\\",proc { |node| (node[:is] == @_root) },true)
		_expr_result = !_var1.empty?
		# END           NODEDESC:[] (TRAVERSE-R)
		# END         TRAVERSE:[\]
		_expr_result = !_var1.empty?
		# END       EXPR:[]
		_local2.each_pair { |var,pnset|
			if _variables.include?(var)
				_variables[var].concat(pnset)
			else
				_variables[var] = pnset
			end
		}
		_expr_result = !_expr_result
		# END     NOT:[]
		return false if (not _expr_result)
	
		_variables.each { |var,pnset|
			if pnset.negative?
				_t_all = _all.dup
				_t_all.concat(pnset)
				_variables[var] = _t_all
			end
		}
		
		return true
	end
	
	def feature_negate2
		_variables = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_universal = []
		
		_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })
		_local1 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN   NOT:[]
		_local2 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_local2 = _variables.dup
		# BEGIN     EXPR:[]
		# BEGIN       TRAVERSE:[/]
		# BEGIN         NODEDESC:[] (TRAVERSE-L)
		_var0 = FDL::Extractor.match_node(@parsetree, proc { |node| not node.nil? })
		_expr_result = !_var0.empty?
		# END           NODEDESC:[] (TRAVERSE-L)
		# BEGIN         NODEDESC:[] (TRAVERSE-R)
		_var1 = _var0.traverse("/",proc { |node| (node[:is] == @_root) },true)
		_expr_result = !_var1.empty?
		# END           NODEDESC:[] (TRAVERSE-R)
		# END         TRAVERSE:[/]
		_expr_result = !_var1.empty?
		# END       EXPR:[]
		_local2.each_pair { |var,pnset|
			if _variables.include?(var)
				_variables[var].concat(pnset)
			else
				_variables[var] = pnset
			end
		}
		_expr_result = !_expr_result
		# END     NOT:[]
		return false if (not _expr_result)
	
		_variables.each { |var,pnset|
			if pnset.negative?
				_t_all = _all.dup
				_t_all.concat(pnset)
				_variables[var] = _t_all
			end
		}
		
		return true
	end
	
	def feature_regex
		_variables = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_universal = []
		
		_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })
		_local1 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN   QUANTIFIER:[x]
		# BEGIN     EXPR:[]
		# BEGIN       BIND:[x] (EXPR)
		_var0 = FDL::Extractor.match_node(@parsetree, proc { |node| ((not node[:word].nil? ) and (not node[:word] =~ /pie/)) })
		_variables['x'] = _var0
		_expr_result = !_var0.empty?
		# END         BIND:[x] (EXPR)
		# END       EXPR:[]
		_universal.push('x') if not _universal.include?('x')
		# END     QUANTIFIER:[x]
		return false if (not _expr_result)
	
		_variables.each { |var,pnset|
			if pnset.negative?
				_t_all = _all.dup
				_t_all.concat(pnset)
				_variables[var] = _t_all
			end
		}
		
		_universal.each { |varname| _variables[varname].universal = true }
		["x"].each { |v| return false if not _variables.include?(v) }
		return [ _variables["x"][:size] ].flatten
	end
	
	def feature_not_rebind_and
		_variables = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_universal = []
		
		_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })
		_local1 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN   AND:[]
		_local2 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_local3 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN     AND:[]
		_local4 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_local5 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN       QUANTIFIER:[x]
		# BEGIN         EXPR:[]
		# BEGIN           BIND:[x] (EXPR)
		_var0 = FDL::Extractor.match_node(@parsetree, proc { |node| not node.nil? })
		_local4['x'] = _var0
		_expr_result = !_var0.empty?
		# END             BIND:[x] (EXPR)
		# END           EXPR:[]
		_universal.push('x') if not _universal.include?('x')
		# END         QUANTIFIER:[x]
		_result2 = _expr_result
		_local4.each { |var,pnset|
		  if pnset.negative?
		    _t_all = _all.dup
		    _t_all.concat(pnset)
		    _local4[var] = _t_all
		  end
		}
		_local5 = _local4.dup
		# BEGIN       OR:[]
		_local6 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_local7 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN         NOT:[]
		_local8 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_local8 = _local6.dup
		# BEGIN           EXPR:[]
		# BEGIN             BIND:[x] (EXPR)
		_var1 = FDL::Extractor.match_node(@parsetree, proc { |node| (node[:is] == @_root) })
		_var1.negative=true
		_local8['x'] = _var1
		_expr_result = !_var1.empty?
		# END               BIND:[x] (EXPR)
		# END             EXPR:[]
		_local8.each_pair { |var,pnset|
			if _local6.include?(var)
				_local6[var].concat(pnset)
			else
				_local6[var] = pnset
			end
		}
		_expr_result = !_expr_result
		# END           NOT:[]
		_result4 = _expr_result
		_local6.each { |var,pnset|
		  if pnset.negative?
		    _t_all = _all.dup
		    _t_all.concat(pnset)
		    _local6[var] = _t_all
		  end
		}
		_local7 = _local6.dup
		# BEGIN         TRUE:[]
		_expr_result = true
		# END           TRUE:[]
		_result5 = _expr_result
		_expr_result = _result4 || _result5
		_local5 = HashSet.join_or(_local6,_local7)
		_variables = HashSet.join_or(_variables,_local5)
		# END         OR:[]
		_result3 = _expr_result
		_expr_result = _result2 && _result3
		_local2 = HashSet.join_and(_local4,_local5)
		_variables = HashSet.join_and(_variables,_local2)
		# END       AND:[]
		_result0 = _expr_result
		_local2.each { |var,pnset|
		  if pnset.negative?
		    _t_all = _all.dup
		    _t_all.concat(pnset)
		    _local2[var] = _t_all
		  end
		}
		_local3 = _local2.dup
		# BEGIN     OR:[]
		_local9 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_local10 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN       NOT:[]
		_local11 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_local11 = _local9.dup
		# BEGIN         EXPR:[]
		# BEGIN           BIND:[x] (EXPR)
		_var2 = FDL::Extractor.match_node(@parsetree, proc { |node| (node[:id] == "pie._0_3") })
		_var2.negative=true
		_local11['x'] = _var2
		_expr_result = !_var2.empty?
		# END             BIND:[x] (EXPR)
		# END           EXPR:[]
		_local11.each_pair { |var,pnset|
			if _local9.include?(var)
				_local9[var].concat(pnset)
			else
				_local9[var] = pnset
			end
		}
		_expr_result = !_expr_result
		# END         NOT:[]
		_result6 = _expr_result
		_local9.each { |var,pnset|
		  if pnset.negative?
		    _t_all = _all.dup
		    _t_all.concat(pnset)
		    _local9[var] = _t_all
		  end
		}
		_local10 = _local9.dup
		# BEGIN       TRUE:[]
		_expr_result = true
		# END         TRUE:[]
		_result7 = _expr_result
		_expr_result = _result6 || _result7
		_local3 = HashSet.join_or(_local9,_local10)
		_variables = HashSet.join_or(_variables,_local3)
		# END       OR:[]
		_result1 = _expr_result
		_expr_result = _result0 && _result1
		_variables = HashSet.join_and(_local2,_local3)
		_variables = HashSet.join_and(_variables,_variables)
		# END     AND:[]
		return false if (not _expr_result)
	
		_variables.each { |var,pnset|
			if pnset.negative?
				_t_all = _all.dup
				_t_all.concat(pnset)
				_variables[var] = _t_all
			end
		}
		
		_universal.each { |varname| _variables[varname].universal = true }
		["x"].each { |v| return false if not _variables.include?(v) }
		return [ _variables["x"][:id] ].flatten
	end
	
	def feature_update_parentof
		_variables = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_universal = []
		
		_all = FDL::Extractor.match_node(@parsetree,proc { |node| not node.nil? })
		_local1 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN   AND:[]
		_local2 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		_local3 = Hash.new { |hash,key| hash[key] = self.send("node_#{key}".to_sym) }
		# BEGIN     QUANTIFIER:[x]
		# BEGIN       EXPR:[]
		# BEGIN         BIND:[x] (EXPR)
		_var0 = FDL::Extractor.match_node(@parsetree, proc { |node| not node.nil? })
		_local2['x'] = _var0
		_expr_result = !_var0.empty?
		# END           BIND:[x] (EXPR)
		# END         EXPR:[]
		_universal.push('x') if not _universal.include?('x')
		# END       QUANTIFIER:[x]
		_result0 = _expr_result
		_local2.each { |var,pnset|
		  if pnset.negative?
		    _t_all = _all.dup
		    _t_all.concat(pnset)
		    _local2[var] = _t_all
		  end
		}
		_local3 = _local2.dup
		# BEGIN     EXPR:[]
		# BEGIN       TRAVERSE:[\*]
		# BEGIN         NODEDESC:[x] (TRAVERSE-L)
		_var1 = _local3['x']
		_var1 ||= _variables['x']
		_expr_result = !_var1.empty?
		# END           NODEDESC:[x] (TRAVERSE-L)
		# BEGIN         NODEDESC:[] (TRAVERSE-R)
		_var2 = _var1.traverse("\*",proc { |node| (node[:is] == @_root) },false)
		_expr_result = !_var2.empty?
		# END           NODEDESC:[] (TRAVERSE-R)
		# END         TRAVERSE:[\*]
		_expr_result = !_var2.empty?
		# END       EXPR:[]
		_result1 = _expr_result
		_expr_result = _result0 && _result1
		_variables = HashSet.join_and(_local2,_local3)
		_variables = HashSet.join_and(_variables,_variables)
		# END     AND:[]
		return false if (not _expr_result)
	
		_variables.each { |var,pnset|
			if pnset.negative?
				_t_all = _all.dup
				_t_all.concat(pnset)
				_variables[var] = _t_all
			end
		}
		
		_universal.each { |varname| _variables[varname].universal = true }
		["x"].each { |v| return false if not _variables.include?(v) }
		return [ _variables["x"][:id] ].flatten
	end
	
end
