require "snarl"
# require 'test/unit' unless defined? $ZENTEST and $ZENTEST

class TestSnarl < Test::Unit::TestCase

  def test_new_api
    assert(Snarl.new('title'))
    assert(Snarl.new('title', 'msg')) 
      
    assert_raises(TypeError) { Snarl.new('title', 'msg', 0) } 
    assert(Snarl.new('title', 'msg', nil)) 
    assert(Snarl.new('title', 'msg', 'missing_file'))
    assert(Snarl.new('title', 'short', nil, 1)) 
  end

  def test_show_api
    assert(Snarl.show_message('title'))
    assert(Snarl.show_message('title', 'msg')) 
      
    assert_raises(TypeError) { Snarl.show_message('title', 'msg', 0) } 
    assert(Snarl.show_message('title', 'msg', nil)) 
    assert(Snarl.show_message('title', 'msg', 'missing_file'))
    assert(Snarl.show_message('title', 'short', nil, 1)) 
  end
  
  def test_update_api
    assert(s = Snarl.new('title'))
    assert(s.update('new title'))    
    assert(s.update('title', 'msg')) 
      
    assert_raises(TypeError) { s.update('title', 'msg', 0) } 
    assert(s.update('title', 'msg', nil)) 
    assert(s.update('title', 'msg', 'missing_file'))
    assert(s.update('title', 'short', nil, 1)) 
  end
  
  def test_visible
    assert(s = Snarl.new('title', 'hold me', nil, 1))
    assert(s.visible?)
    assert(s.hide)
  end  
    
  # this one is a little fragile, but it passes right now...
  def test_version
    assert_equal("1.1", Snarl.version)
  end
end