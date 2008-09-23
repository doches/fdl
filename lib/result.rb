module FDL

class ExpressionResult
  attr_accessor :match,:binding
  
  def initialize(bool,binding=false)
    @match=bool
    @binding=binding
  end
  
  def is_true?
    return @match || @binding
  end
  
  def and(bool,another=nil)
    if bool.is_a? ExpressionResult
      return ExpressionResult.new(@match && bool.match, @binding && bool.binding)
    elsif bool.is_a? TrueClass or bool.is_a? FalseClass or bool.is_a? NilClass
      bool2 = (another.nil? ? bool : another)
      return ExpressionResult.new(@match && bool,@binding && bool2)
    else
      throw "Cannot combine an ExpressionResult with object of type #{bool.class}"
    end
  end
  
  def or(bool,another=nil)
    if bool.is_a? ExpressionResult
      return ExpressionResult.new(@match || bool.match, @binding || bool.binding)
    elsif bool.is_a? TrueClass or bool.is_a? FalseClass or bool.is_a? NilClass
      bool2 = (another.nil? ? bool : another)
      return ExpressionResult.new(@match || bool,@binding || bool2)
    else
      throw "Cannot combine an ExpressionResult with object of type #{bool.class}"
    end
  end
  
  def negate!
    @match = !@match
  end
  
  def negate
    return ExpressionResult.new(!@match,@binding)
  end
end

end
