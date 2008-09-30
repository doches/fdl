require 'test/unit'
require 'lib/xml2pt'
require 'lib/parsenode'

class ParseNodeTest < Test::Unit::TestCase
  # Load "I eat pie." from data/
  def setup
    @sentence = XMLSentence.xml2parsetree('test/pie.xml')[0]
    ParseNodeSet.tree=@sentence
  end
  
  def test_rand_range
    100.times do
      r = rand_range(0.5,1.5)
      assert r >= 0.5
      assert r <= 1.5
    end
  end
  
  def teardown
    ;
  end
  
  def test_overlap
    a = ParseNodeSet.new(@sentence.root)
    b = a.traverse("\\", proc { |n| not n.nil? })
    assert !(a.overlap?(b))
    assert !(b.overlap?(a))
    c = b.dup
    c.concat(a)
    assert a.overlap?(c)
    assert b.overlap?(c)
    assert c.overlap?(a)
    assert c.overlap?(b)
  end
  
  def test_root
    assert(@sentence.root[:id] == "pie._0_502")
    assert(@sentence.root[:cat] == "S")
  end
  
  def test_children_indices
    children = @sentence.root.children
    assert(children.get(0)[:index] < @sentence.root[:index])
    assert(children.get(1)[:index] > @sentence.root[:index])
  end
  
  def test_children
    children = @sentence.root.children
    assert_equal 2, children.size
    
    cset = ParseNodeSet.new(children)
    assert_equal 2, cset.size
  end
   
  def test_traverse_children
    root = ParseNodeSet.new(@sentence.root)
    children = root.traverse("\\", proc { |node| not node.nil? })
    assert_equal 2,children.size

    assert(children == @sentence.root.children)
    assert(children == root.children)
  end
  
  def test_traverse_parent
    root = ParseNodeSet.new(@sentence.root)
    root.children.each { |node| 
      above = node.traverse("/", proc { |node| not node.nil? })
      assert(above == root)
    }
  end
  
  def test_traverse_dominated_simple
    children = ParseNodeSet.new(@sentence.root.children)
    
    children.each { |node|
      dominated_by = node.traverse("/*", proc { |node| not node.nil? })
      assert_equal ParseNodeSet.new([@sentence.root,node]), dominated_by
    }
  end
  
  def test_traverse_dominate_simple
    dominated = @sentence.root.traverse("\*", proc { |node| not node.nil? }) 
    dominated = ParseNodeSet.new(@sentence.root).traverse("\*", proc { |node| not node.nil? }) 
    all = ParseNodeSet.new(@sentence.nodes.values)
    assert_equal all, dominated
  end
  
  def test_dominated2
    zero = @sentence.nodes[:"pie._0_0"]
    zero_and_root = zero.traverse("/*", proc { |node| not node.nil? })
    assert_equal 2, zero_and_root.size
    assert_equal ParseNodeSet.new([zero,@sentence.root]), zero_and_root
  end
  
  def test_sibling
    pie = @sentence.nodes[:"pie._0_2"]
    dot = @sentence.nodes[:"pie._0_3"]

    assert_equal ParseNodeSet.new(dot), pie.traverse(">|", proc { |n| not n.nil? })
    assert_equal ParseNodeSet.new(pie), dot.traverse("<|", proc { |n| not n.nil? })
    
    root = @sentence.nodes[:"pie._0_502"]
    assert_equal ParseNodeSet.new, root.traverse("<|", proc { |n| not n.nil? })
    assert_equal ParseNodeSet.new, root.traverse(">|", proc { |n| not n.nil? })
    
    vp = @sentence.nodes[:"pie._0_501"]
    i = @sentence.nodes[:"pie._0_0"]
    assert_equal ParseNodeSet.new(vp), i.traverse(">|", proc { |n| not n.nil? })
    assert_equal ParseNodeSet.new(i), vp.traverse("<|", proc { |n| not n.nil? })
  end
  
  def test_leftof_rightof
    i = @sentence.nodes[:"pie._0_0"]
    eat = @sentence.nodes[:"pie._0_1"]
    pie = @sentence.nodes[:"pie._0_2"]
    dot = @sentence.nodes[:"pie._0_3"]
    s = @sentence.nodes[:"pie._0_502"]
    vp = @sentence.nodes[:"pie._0_501"]
    npb = @sentence.nodes[:"pie._0_500"]

    assert_equal ParseNodeSet.new([dot]), dot.traverse(">*", proc { |n| not n.nil? })
    assert_equal ParseNodeSet.new([dot,npb]), npb.traverse(">*", proc { |n| not n.nil? })
    assert_equal ParseNodeSet.new([i,eat,pie,dot,s,vp,npb]), i.traverse(">*", proc { |n| not n.nil? })

    assert_equal ParseNodeSet.new([i]), i.traverse("<*", proc { |n| not n.nil? })
    assert_equal ParseNodeSet.new([i,s]), s.traverse("<*", proc { |n| not n.nil? })
    assert_equal ParseNodeSet.new([i,eat,pie,dot,s,vp,npb]), dot.traverse("<*", proc { |n| not n.nil? })
  end
  
  def test_concat
    a = @sentence.nodes[:"pie._0_0"]
    b = @sentence.nodes[:"pie._0_1"]
    c = @sentence.nodes[:"pie._0_1"]
    
    sa = ParseNodeSet.new(a)
    sb = ParseNodeSet.new(b)
    sc = ParseNodeSet.new(c)
    sc.negative=true
    
    sa.concat(sb)
    assert_equal ParseNodeSet.new( [a,b] ), sa
    
    sa.concat(sc)
    assert_equal ParseNodeSet.new( a ), sa
  end
end
