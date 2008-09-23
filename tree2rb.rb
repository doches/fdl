#!/usr/bin/ruby

require 'lib/node'
require 'lib/feature'
require 'lib/nodetype'
require 'yaml'

include FDL

input = ARGV[0]
if input.nil?
  input = ""
  STDIN.each_line { |l| input += l }
  input = YAML.load(input)
else
  input = YAML.load_file(input)
end

features = []
nodetypes = []
input.each { |feature|
  if feature.respond_to? :typename
    case feature.typename
      when "NODE"
        nodetypes.push NodeType.new(feature)
      when "FEATURE"
        features.push Feature.new(feature)
    end
  end
}

code = <<CODE
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
CODE
code += "\t\t@features = ["+(features.map { |x| ":"+x.name }).join(", ")+"]\n"
code += <<CODE
	end
	
	def featurize
	  return @features.map { |method| self.send(method.to_sym) }
	end
	
  def method_missing(sym)
    var = "\#{sym}"
    var = var[var.index("_")+1..var.size] if var.index("_")
    feature = nil
    caller.each { |line|
      if line.include?("feature_")
        feature = line[line.index("feature_")+8..(line.size-1)]
        break
      end
    }
    raise "Missing method (probably due to unbound variable '\#{var}') called in feature '\#{feature}'"
  end

CODE
nodetypes.each { |nodetype| code += "\t"+nodetype.to_s.gsub("\n","\n\t")+"\n" }
features.each { |feature| code += "\t"+feature.to_s.gsub("\n","\n\t")+"\n" }
code += <<CODE
end
CODE

print code
