#!/usr/bin/ruby

require 'rexml/document'
require 'lib/parsenode'

class XMLSentence
  attr_reader :root,:predicates,:nodes
  
  def initialize(sentence)
    @nodes = {}
    sentence.elements.each("terminals/t") { |terminal| 
      node = ParseNode.new
      id = terminal.attributes["id"]
      terminal.attributes.each { |attr,value| node[attr.to_sym] = value }
      nodes[id.to_sym] = node
    }
    fixme = []
    sentence.elements.each("nonterminals/nt") { |nonterm|
      node = ParseNode.new
      id = nonterm.attributes["id"]
      nonterm.attributes.each { |attr,value| node[attr.to_sym] = value }
      nodes[id.to_sym] = node
      nonterm.elements.each("edge") { |edge|
        child = nodes[edge.attributes["idref"].to_sym]
        if not child.nil?
          node.children.push( child )
          child.parent = node
        else
          fixme.push [node,edge.attributes["idref"]]
        end
      }
    }
    fixme.each { |node,child_id| 
      node.children.push(nodes[child_id.to_sym])
      nodes[child_id.to_sym].parent = node
    }
    #nodes.each { |n| print n[0]," -> ",n[1].children.map{|x|x[:id]}.join(", "),"\n"}
    @root = nodes[sentence.attributes["root"].to_sym]
    @nodes = nodes
    @predicates = []
    @nodes.each { |key,node| @predicates.push(node) if not node[:cat].nil? and node[:cat].include?("V") }
#    @nodes = @nodes.map {|x| x[1]}
#    @root.print_tree
#    print "\n"
  end

  # Load sentences from either an existing XML file or XML input.
  # Returns an array of XMLSentence objects.
  def XMLSentence.xml2parsetree(xml)
    sentences = []
  
    xml = File.new(xml) if File.exists?(xml)
  
    xml = REXML::Document.new xml
    xml.elements.each("corpus/body/s/graph") { |sentence|
      sent = XMLSentence.new(sentence)
      sent.generate_indices
      sentences.push sent
    }
    return sentences
  end
  
  def generate_indices
    index = @root.children.size/2.0
    index = index.floor if index % 1 != 0
    @root.generate_indices(1.0)
  end
end

if $0 == __FILE__
  input = ""
  STDIN.each_line { |l| input += l }
  s = XMLSentence.xml2parsetree(input)
  s.each {|x| 
    x.root.print_tree(0,:id)
  }
end
