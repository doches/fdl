require 'test/unit'
require 'test/testlib'
require 'lib/xml2pt'
require 'tmpdir'

class AspectTest < Test::Unit::TestCase
  include TestBench

  def initialize(args)
    super(args)
    TestBench.keys = ["pie._0_501 pie._0_501",
                      "pie._0_501 pie._0_502", 
                      "pie._0_501 pie._0_0",
                      "pie._0_501 pie._0_1",
                      "pie._0_501 pie._0_2", 
                      "pie._0_501 pie._0_3", 
                      "pie._0_501 pie._0_500"]
  end
  
  # Load pie.xml into ParseNodes (@sentences)
  def setup
    load("test/pie.xml")
  end

  # Example features and reference output.
  def test_a
    fdl_test( %{
      feature test
        (not all(x,x:[word=nil]))
        <x.id>},
      false)
  end
  
  def test_b
    ref = %w{pie._0_0 pie._0_1 pie._0_2 pie._0_3}
    fdl_test( %{
      feature test
        (not all(x,x:[word=nil])) or true
        <x.id>}, 
      :id => [ref])
  end
  
  def test_true
    fdl_test( %{
      feature t
        false or true},
       true)
  end

  def test_false
    fdl_test( %{
      feature f
        false and true},
       false)
  end
      
  def test_empty
    fdl_test( %{
      feature test
        (x:[word=nil] and x:[word!=nil]) and not empty(x)},
      false)
  end
  
  def test_is
    fdl_test( %{
      feature test
        x:[is=root]
        <x.id>},
      :id => [%w{pie._0_502}])
  end
  
  def test_self
    fdl_test( %{
      feature test
        x:[is=self]
        <x.id>},
      :id => %w{pie._0_501 pie._0_502 pie._0_0 pie._0_1 pie._0_2 pie._0_3 pie._0_500})
  end
end
