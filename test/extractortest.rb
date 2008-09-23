require 'test/unit'
require 'lib/xml2pt'
require 'lib/parsenode'
require 'lib/extractor'

class ExtractorTest < Test::Unit::TestCase
  # Load "I eat pie." from data/
  def setup
    @sentence = XMLSentence.xml2parsetree('data/pie.xml')[0]
    ParseNodeSet.tree=@sentence
    
    @root = @sentence.root
  end

  def teardown
    ;
  end

  def test_root
    assert_equal ParseNodeSet.new(@root), FDL::Extractor.match_node(@root,proc { |node| node[:is] == @sentence.root })
    assert_equal ParseNodeSet.new(@root), FDL::Extractor.match_node(@root,proc { |node| node[:id] == @sentence.root[:id] })
  end
  
  def test_all
    assert_equal ParseNodeSet.new(@sentence.nodes.values), FDL::Extractor.match_node(@root,proc { |node| not node.nil? })
  end
  
  def test_properties
    i = @sentence.nodes[:"pie._0_0"]
    assert_equal ParseNodeSet.new(i), FDL::Extractor.match_node(@root,proc { |node| node[:id] == "pie._0_0"})
    assert_equal ParseNodeSet.new(i), FDL::Extractor.match_node(@root,proc { |node| node[:word] == "I"})
  end
end
