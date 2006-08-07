You must install snarl for this to work: http://www.fullphat.net/snarl.html,
it is a GPL growl like notification system for Win32.

I saw zenspiders autotest movie and cried once again that for a variety of 
reasons primarly centered around my employment I am still using a Win32 
platform for development. What beautiful test notifications -- I needed it. 

I decided it would be much easier to implement then to get my office manager to
get me a Mac (not to mention most of my customers are using Win32), so I 
started looking into the issue. At the South East Michigan Ruby Users Group
(www.rubymi.org) I mentioned it and Winston Tsang mentioned snarl and even 
found the somewhat difficult to google for link. 

I started writing a C extention, but remembered DL and decided it would be much
easier to distrubute a pure ruby extension -- so here it is.

I would like to thank Gordon Thiesfeld, he found the great icons at 
famfamfam.com and I stole much of his autotest (in preference to the)
one I originally wrote -- of course I hacked it up, so if anything does
not work I am sure it is all my fault. He also helped layout the code
for gemification.

If you have any problems please let me know. Also if you have any pointers 
on providing tests for this code please contact me.


----------------------------
A few autotest notes, I changed line 71 in autotest.rb 

*** autotest.rb Mon Aug  7 12:47:30 2006
--- \tmp\autotest.rb  Mon Aug  7 12:20:29 2006
***************
*** 68,74 ****
      @files = Hash.new Time.at(0)
      @files_to_test = Hash.new { |h,k| h[k] = [] }
      @exceptions = false
!     @libs = '.:lib:test'
      @output = $stderr
      @sleep = 2
    end
--- 68,74 ----
      @files = Hash.new Time.at(0)
      @files_to_test = Hash.new { |h,k| h[k] = [] }
      @exceptions = false
!     @libs = %w[. lib test].join(File::PATH_SEPARATOR)
      @output = $stderr
      @sleep = 2
    end
***************


And if you are using a 4NT (www.jpsoft.com) shell, this helps as well (works 
fine if you are using cmd.exe)

*** 208,214 ****
  
      unless full.empty? then
        classes = full.map {|k,v| k}.flatten.join(' ')
!       cmds << "#{ruby} -I#{@libs} -rtest/unit -e \"%w[#{classes}].each { |f| load f }\" | unit_diff -u"
      end
  
      partial.each do |klass, methods|
--- 208,214 ----
  
      unless full.empty? then
        classes = full.map {|k,v| k}.flatten.join(' ')
!       cmds << "#{ruby} -I#{@libs} -rtest/unit -e \"%%w[#{classes}].each { |f| load f }\" | unit_diff -u"
      end
  
      partial.each do |klass, methods|
