require 'lib/result'
require 'test/unit'

class ResultTest < Test::Unit::TestCase
  include FDL
  
  def test_istrue
    assert_equal true, ExpressionResult.new(true,true).is_true?
    assert_equal true, ExpressionResult.new(true,false).is_true?
    assert_equal true, ExpressionResult.new(false,true).is_true?
    assert_equal false, ExpressionResult.new(false,false).is_true?
  end
  
  def test_negate
    assert_equal true, ExpressionResult.new(true,true).negate.is_true?
    assert_equal false, ExpressionResult.new(true,false).negate.is_true?
    assert_equal true, ExpressionResult.new(false,true).negate.is_true?
    assert_equal true, ExpressionResult.new(false,false).negate.is_true?
  end
  
  def test_and
    assert_equal false, ExpressionResult.new(true,true).and(false).is_true?
    assert_equal false, ExpressionResult.new(true,false).and(false).is_true?
    assert_equal false, ExpressionResult.new(false,false).and(false).is_true?
    assert_equal false, ExpressionResult.new(false,true).and(false).is_true?
  end
  
  def test_negate!
    result = ExpressionResult.new(true,true)
    result.negate!
    assert_equal true, result.binding
    assert_equal false, result.match
  end
  
  def test_or
    result = ExpressionResult.new(true,false).or(ExpressionResult.new(false,true))
    assert_equal true, result.match
    assert_equal true, result.binding
    result = ExpressionResult.new(false,false).or(ExpressionResult.new(true,true))
    assert_equal true, result.match
    assert_equal true, result.binding
    result = ExpressionResult.new(false,false).or(ExpressionResult.new(true,false))
    assert_equal true, result.match
    assert_equal false, result.binding
    result = ExpressionResult.new(false,false).or(ExpressionResult.new(false,false))
    assert_equal false, result.match
    assert_equal false, result.binding
  end
end
