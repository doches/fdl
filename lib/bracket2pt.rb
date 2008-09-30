#!/usr/bin/ruby

require 'rexml/document'
require 'lib/parsenode'

class BracketSentence
  attr_reader :root,:predicates,:nodes
  
  def initialize(sentence)
    @root = generate(sentence)

    # Nodes
    id = (Time.now.to_f * 100000 % 100000000000).to_i
    i = 0
    @nodes = {}
    bucket = [@root]
    while not bucket.empty?
      elem = bucket.shift
      if not elem.nil?
        bucket = [bucket,elem.children.set].flatten
        elem[:id] = "#{id}.#{i}"
        @nodes[elem[:id]] = elem
        i += 1
      end
    end
    
    # Predicates
    @predicates = []
    @nodes.each { |key,node| @predicates.push(node) if not node[:cat].nil? and node[:cat].include?("V") }
    
    # Assign indices
    @root.generate_indices(1.0)
  end
  
  def generate(str,i=0)
    node = ParseNode.new
    
    chunk = BracketSentence.next_chunk(str)
    cat = chunk[1..chunk.index(" ")]
    node[:cat] = cat.strip
    if chunk =~ /^\([^\(\)]+ ([^\)\(]+)\)$/
      node[:word] = $1
    end
    
    next_chunk = BracketSentence.next_chunk(chunk[cat.size,chunk.size])
    remain = chunk[cat.size..chunk.size-2]
    if not remain.nil? and not next_chunk.nil?
      if remain.strip == next_chunk.strip
        node.children.push generate(next_chunk,i+1)
      else
      loop do
        node.children.push generate(next_chunk,i+1)
        break if remain.strip == next_chunk.strip
        remain = remain[next_chunk.size..remain.size-1]
        next_chunk = BracketSentence.next_chunk(remain)
      end
      end
    end
    
    return node
  end
  
  def BracketSentence.next_chunk(str)
    l = str.index("(")
    c = 0
    s = false
    index = str.size
    return nil if l.nil? or l > str.size
    (l..str.size).each { |i|
      case str[i].chr
        when "("
          c += 1
          s = true
        when ")"
          c -= 1
      end
#      print "#{str[i].chr}-#{c}|"
      if s and c == 0
        index = i
        break
      end
    }
    return str.slice(l,index+1)
  end

  def BracketSentence.file2parsetree(file)
    throw "File #{file} not found!" if not File.exists?(file)
    
    fin = File.open(file,"r")
    input = ""
    fin.each_line { |l| input += l }
    fin.close
    return BracketSentence.lines2parsetree(input)
  end

  def BracketSentence.lines2parsetree(lines)
    sentences = []
  
    lines.each do |line|
      sentence = BracketSentence.new(line)
      sentence.generate_indices
      sentences.push sentence
    end
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
  s = BracketSentence.lines2parsetree(input)
  s.each {|x| 
    x.root.print_tree(0,:id)
  }
end
