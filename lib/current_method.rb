# From http://www.ruby-forum.com/topic/75258
# 12 June 2008
# Originally by Robert Klemme

module Kernel
   def this_method
     caller[0] =~ /`([^']*)'/ and $1
   end
end
