require 'test/unit'

# List of files to specifically ignore, including this one
ignore = ["test.rb"]

# Include all valid tests in test/
Dir.foreach("test/") { |file|
  if not ignore.include? file and not file =~ /(~$|^\.)/ and file =~ /test\.rb$/
    require "test/#{file}"
    print "Loaded test/#{file}\n"
  end
}
