module FDL

class Node
  attr_accessor :type,:string,:left,:right,:indent,:key
  def initialize(fline)
    @indent = fline[0]
    @key,@type,@string,@left,@right = fline[1].strip.split(":")
  end
  
  def typename
    @type
  end
  
  def to_s
    str = ""
    @indent.times { str += " " }
    str += "#{@type}:[#{@string}]"
  end
  
  def print_tree(io=STDOUT)
    io.print self.to_s,"\n"
    @left.print_tree if not @left.nil?
    @right.print_tree if not @right.nil?
  end
  
  def get_tree
    str = "#{self.to_s}\n"
    str += "\t#{@left.get_tree}\n" if not @left.nil?
    str += "\t#{@right.get_tree}\n" if not @right.nil?
    return str
  end
end

end
