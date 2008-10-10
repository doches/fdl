#!/usr/bin/ruby

require 'optparse'
require 'ostruct'

options = OpenStruct.new
options.format=:auto
optparser = OptionParser.new do |opts|
  opts.banner = "Usage: ./test.rb path/to/input.xml [options]"
  opts.banner = <<USE
test.rb featurizes preprocessed input, which can be either SalsaTiger XML
preprocessed by Shalmaneser, or Treebank bracketed parse trees, one tree per
line.

Usage: ./test.rb path/to/feature_extractor.rb path/to/input [OPTIONS]
  OR
Usage: cat input | ./test.rb path/to/feature_extractor.rb [OPTIONS]

OPTIONS
USE
  
  opts.on("--format [TYPE]",[:xml, :treebank,:auto],
          "Select input type (xml, treebank,auto)",
          "  Default is AUTO, which will treat input from STDIN and with a .xml",
          "  file extension as XML, and all other input as TREEBANK") do |format|
    options.format = format
  end
   
  opts.on_tail("-h","--help","Show this help text") do
    puts opts
    exit
  end
end

begin
  optparser.parse!
rescue 
  ; # We were given invalid options: run with defaults and see what happens!
end

# Get parse tree(s)
input = ""
sentences = nil
if not ARGV[1].nil?
  IO.foreach(ARGV[1]) { |l| input += l }
  if (options.format == :auto and ARGV[1] =~ /\.xml$/) or options.format == :xml
    require 'lib/xml2pt'
    sentences = XMLSentence.xml2parsetree(input)
  else
    require 'lib/bracket2pt'
    sentences = BracketSentence.lines2parsetree(input.split("\n"))
  end
else
  STDIN.each_line { |l| input += l }
  
  if options.format == :xml
    require 'lib/xml2pt'
    sentences = XMLSentence.xml2parsetree(input)
  elsif options.format == :treebank
    require 'lib/bracket2pt'
    sentences = BracketSentence.lines2parsetree(input.split("\n"))
  elsif options.format == :auto
    require 'lib/xml2pt'
    sentences = XMLSentence.xml2parsetree(input)
    if sentences.empty?
      begin
        require 'lib/bracket2pt'
        sentences = BracketSentence.lines2parsetree(input.split("\n"))
      rescue NoMethodError
        STDERR.print "Unknown input format -- FDL only understands SalsaTigerXML and treebank-style trees, one tree per line\n"
        exit(1)
      end
    end
  end
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
