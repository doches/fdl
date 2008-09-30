require 'test/unit'
require 'lib/parsenode'
require 'lib/bracket2pt'

class BracketTest < Test::Unit::TestCase
  # TODO: add real unit test for correct, not just successful, loading.
  
  # Can we load successfully?
  def test_parse
    @tree = BracketSentence.new("(TOP (S (NP (PRP He) ) (VP (VBD told) (NP (PRP me) ) (PP (IN so) (NP (PRP himself) ) ) ) (. .) ) )") if @tree.nil?
    
    assert @tree.root
    assert @tree.nodes
    assert @tree.predicates
  end
  
  # Test next_chunk method used to parse
  def test_chunk
    str = "(NP (DET The) (N dog) )"
    assert_equal "(NP (DET The) (N dog) )", BracketSentence.next_chunk(str).strip
    str = "(DET The) (N dog) )"
    assert_equal "(DET The)", BracketSentence.next_chunk(str).strip
  end
end
