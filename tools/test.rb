#!/usr/bin/ruby

# Get parse tree(s)
input = ""
sentences = nil
if not ARGV[1].nil?
  IO.foreach(ARGV[1]) { |l| input += l }
  if ARGV[1] =~ /\.xml/
    require 'lib/xml2pt'
    sentences = XMLSentence.xml2parsetree(input)
  else
    require 'lib/bracket2pt'
    sentences = BracketSentence.lines2parsetree(input.split("\n"))
  end
else
  require 'lib/xml2pt'
  STDIN.each_line { |l| input += l }
  sentences = XMLSentence.xml2parsetree(input)
end

# Get features
feature_file = ARGV[0]
require "#{feature_file}"

# Print header
extractor = FeatureExtractor.new(sentences[0].root,sentences[0].root,sentences[0].root,sentences[0].root)
print "<",(extractor.features.map { |method| method.to_s.gsub("feature_","") }).join(", "),">\n"

# Featurize!
sentences.each { |sent|
  sent.predicates.each { |predicate|
    sent.nodes.each { |node|
      extractor = FeatureExtractor.new(sent.root,node[1],sent.root,predicate)
      print "[target=#{predicate[:id]}, self=#{node[0]}]:\t"
      print "\t#{extractor.featurize.inspect}\n"
    }
  }
}
