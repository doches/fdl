require 'lib/hash'
require 'test/unit'
require 'lib/parsenodeset'

class HashTest < Test::Unit::TestCase
  def setup
    @a = {}
    @b = {}
    @a[:x] = [:a,:b,:c]
    @a[:y] = [:a,:b]
    @b[:x] = [:b,:c,:d]
    @b[:y] = [:c]
    @sentence = XMLSentence.xml2parsetree('data/pie.xml')[0]
    ParseNodeSet.tree=@sentence
  end
  
  def test_negative
    a = ParseNodeSet.new([@sentence.root,@sentence.nodes[:"pie._0_0"]])
    b = ParseNodeSet.new(@sentence.nodes[:"pie._0_0"])
    b.negative=true
    
    ha = {"x" => a}
    hb = {"x" => b}
    
    hc = HashSet.join_and(ha,hb)
    correct = {"x" => ParseNodeSet.new(@sentence.root) }
    assert_equal correct,hc
  end
    
  def disable_test_union
    res = HashSet.union(@a,@b)
    test = {}
    test[:x] = [:a,:b,:c,:d]
    test[:y] = [:a,:b,:c]
    res.each { |k,v| res[k] = v.set} 
    assert_equal test,res
  end
  
  def disable_test_intersection
    res = HashSet.intersection(@a,@b)
    test = { :x => [:b,:c],
             :y => []
           }
    res.each{ |k,v| res[k] = v.set }
    assert_equal test,res
  end
  
  def test_delete
    c = @a.dup
    c = HashSet.delete(c,{:x => [:c],:y => [:b,:c]})
    test = { :x => [:a,:b], :y => [:a]}
    assert_equal test,c
  end
end
