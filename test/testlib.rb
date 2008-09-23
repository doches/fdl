require 'test/unit'
require 'test/testlib'
require 'lib/xml2pt'
require 'tmpdir'

module TestBench
  @@keys = nil
  
  def TestBench.keys
    @@keys
  end
  
  def TestBench.keys=(keys)
    @@keys = keys
  end
  
  def format_correct(correct)
    keys = @@keys.dup
    reference = {}
    keys.each { |key| reference[key] = nil }
    if correct.is_a? TrueClass or correct.is_a? FalseClass
      reference.each_key { |key| reference[key] = correct }
    elsif correct.include?(:id)
      if correct[:id].size == 1
        correct[:id] = correct[:id][0] if correct[:id].is_a? Array
        reference.each_key { |key| reference[key] = [correct[:id]][0] }
      else
        i = 0
        reference.each_key { |key| reference[key] = [correct[:id][i]]; i += 1 }
      end
    end
    return reference
  end
  
  def fdl_test(fdl,correct)
    output = create_feature(fdl)
    correct = format_correct(correct)
    assert_equal correct,output
  end

  def initialize(x)
    super
    @@sentences = nil
    @@file = nil
  end
  
  # Load pie.xml into ParseNodes (@sentences)
  def load(file)
    return if not @@sentences.nil? and @@file == file
    xml = ""
    IO.foreach(file) { |line| xml += line }
    @@sentences = XMLSentence.xml2parsetree(xml)
    @@file = file
  end
  
  def create_feature(fdl)
    file = write_to_file(fdl)
    `tools/generate.rb #{file} -noedit`
    file = file.gsub(/fdl$/,"rb")
    Kernel.load file
    extractor = FeatureExtractor.new(@@sentences[0].root,@@sentences[0].root,@@sentences[0].root,@@sentences[0].root)
    feature = extractor.features.map { |method| method.to_s.gsub("feature_","") }[0]
    output = {}
    @@sentences[0].predicates.each { |predicate|
      @@sentences[0].nodes.each { |node|
        extractor = FeatureExtractor.new(@@sentences[0].root,node[1],@@sentences[0].root,predicate)
        output["#{predicate[:id]} #{node[0]}"] = extractor.featurize[0]
      }
    }
    return output
  end
  
  def write_to_file(string,fname=nil)
    fname ||= File.join(Dir.tmpdir,"featuretest.fdl")
    f = File.new(fname,"w")
    f.puts string
    f.close
    return fname
  end
end
