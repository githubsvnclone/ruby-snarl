require 'snarl'

module AutoSnarl  
  def self.icon
    # icons from http://www.famfamfam.com/lab/icons/silk/
    path = File.join(File.dirname(__FILE__), "/../icons")
    {
      :green => "#{path}/accept.png",
      :red    => "#{path}/exclamation.png",
      :info   => "#{path}/information.png"
    }
  end
  
  def self.snarl title, msg, icon = nil, time=2
    Snarl.show_message(title, msg, icon, time)
  end

  Autotest.add_hook :run do  |at|
    snarl "Run", "Run" unless $TESTING
  end

  Autotest.add_hook :red do |at|
    failed_tests = at.files_to_test.inject(0){ |s,a| k,v = a;  s + v.size}
    snarl "Tests Failed", "#{failed_tests} tests failed", 2, icon[:red]
  end

  Autotest.add_hook :green do |at|
    snarl "Tests Passed", "All tests passed", 2, icon[:green] #if at.tainted 
  end

  Autotest.add_hook :run do |at|
    snarl "autotest", "autotest was started", 2, icon[:info] unless $TESTING
  end

  Autotest.add_hook :interrupt do |at|
    snarl "autotest", "autotest was reset", 2, icon[:info] unless $TESTING
  end

  Autotest.add_hook :quit do |at|
    snarl "autotest", "autotest is exiting", 2, icon[:info] unless $TESTING
  end

  Autotest.add_hook :all do |at|_hook
    snarl "autotest", "Tests have fully passed", 2, icon[:green] unless $TESTING
  end

end
