#!/usr/bin/ruby
require 'lib/xml2pt'
require 'test/unit'

class FeatureTest < Test::Unit::TestCase
  def test_aaaagenerate
    assert system("ruby tools/generate.rb test/features.fdl -noedit")
  end
  
  def test_apply
    # Get parse tree(s)
    sentences = XMLSentence.xml2parsetree(File.readlines("test/pie.xml").join)

    # Get features
    feature_file = "test/features.rb"
    require "#{feature_file}"

    # Print header
    extractor = FeatureExtractor.new(sentences[0].root,sentences[0].root,sentences[0].root,sentences[0].root)
    features = extractor.features.map { |method| method.to_s.gsub("feature_","") }

    # Load Correct results
    correct = YAML.load_file("test/features.correct.yaml")

    # Featurize
    sentences.each { |sent|
      sent.predicates.each { |predicate|
        sent.nodes.each { |node|
          # Set correct results
          correct[4] = ["#{node[0]}"]
          
          # Featurize and compare
          extractor = FeatureExtractor.new(sent.root, node[1], sent.root, predicate)
          results = extractor.featurize
          results.each_with_index { |feature_result,i|
            assert_equal correct[i],feature_result,"Error in feature #{features[i]} (self=#{node[0]},target=#{predicate[:id]})"
          }
        }
      }
    }
  end
end
