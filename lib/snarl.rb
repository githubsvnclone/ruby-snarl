require 'dl/import'
require 'dl/struct'

# Snarl (http://www.fullphat.net/snarl.html) is a simple notification system, 
# similar to Growl under OSX. This is a simple pure Ruby wrapper to the 
#native API (using DL).
class Snarl
  
  # This is the lowlevel API implemenation using DL and a few handy 
  # constants from the snarl api and the Win32 API
  # Note that I have jump through some hoops to get the array of 
  # characters to work corretly -- if you know a better way please
  # send me (phurley@gmail.com) a note.
  module SnarlAPI
    extend DL::Importable
    dlload 'User32.dll'
    extern "HWND FindWindow(const char*, const char*)"
    extern "BOOL IsWindow(HWND)"
    extern "int SendMessage(HWND, uint, uint, void*)"
    
    SNARL_SHOW = 1
    SNARL_HIDE = 2
    SNARL_UPDATE = 3
    SNARL_IS_VISIBLE = 4
    SNARL_GET_VERSION = 5
    SNARL_REGISTER_CONFIG_WINDOW = 6
    SNARL_REVOKE_CONFIG_WINDOW = 7
    SNARL_TEXT_LENGTH = 1024
    WM_COPYDATA = 0x4a
  
    SnarlStruct = struct [
      "int cmd",
      "long id",
      "long timeout",
      "long data2",
      "char title[#{SNARL_TEXT_LENGTH}]",
      "char text[#{SNARL_TEXT_LENGTH}]", 
      "char icon[#{SNARL_TEXT_LENGTH}]",                     
    ]
  
    CopyDataStruct = struct [
      "long dwData",
      "long cbData",
      "void* lpData",
    ]
  
    # character array hoop jumping, we take the passed string and convert
    # it into an array of integers, padded out to the correct length
    # to_cha --> to character array
    # I do this as it seems necessary to fit the DL API, if there is a 
    # better way please let me know
    def self.to_cha(str)
      result = str.split(/(.)/).map { |ch| ch[0] }.compact
      result + Array.new(SNARL_TEXT_LENGTH - result.size, 0)
    end
    
    # Send the structure off to snarl, the routine will return (if everything
    # goes well) the result of SendMessage which has an overloaded meaning
    # based upon the cmd being sent
    def self.send(ss)
      if isWindow(hwnd = findWindow(nil, 'Snarl'))
        cd = CopyDataStruct.malloc
        cd.dwData = 2
        cd.cbData = ss.size
        cd.lpData = ss.to_ptr
        sendMessage(hwnd, WM_COPYDATA, 0, cd.to_ptr)
      end
    end
  end
  
  include SnarlAPI  
  DEFAULT_TIMEOUT = 3
  
  # Create a new snarl message, the only thing you need to send is a title
  # note that if you decide to send an icon, you must provide the complete
  # path
  def initialize(title, msg=" ", icon=nil, timeout=DEFAULT_TIMEOUT)
    @ss = SnarlStruct.malloc
    show(title, msg, icon, timeout)
  end
      
  # a quick and easy method to create a new message, when you don't care
  # to access it again
  def self.show_message(title, msg=" ", icon=nil, timeout=DEFAULT_TIMEOUT)
    Snarl.new(title, msg, icon, timeout)
  end

  # Update an existing message, it will return true/false depending upon
  # success (it will fail if the message has already timed out or been 
  # dismissed)
  def update(title,msg=" ",icon=nil)
    @ss.cmd = SNARL_UPDATE
    @ss.title = SnarlAPI.to_cha(title)
    @ss.text = SnarlAPI.to_cha(msg)
    icon = File.expand_path(icon)
    @ss.icon = SnarlAPI.to_cha(icon) if icon && File.exist?(icon)
    send?    
  end
  
  # Hide you message -- this is the same as dismissing it
  def hide
    @ss.cmd = SNARL_HIDE
    send?
  end

  # Check to see if the message is still being displayed   
  def visible?
    @ss.cmd = SNARL_IS_VISIBLE
    send?
  end
  
  # Return the current version of snarl (not the snarl gem) as a character
  # string "1.0" format
  def self.version
    ss = SnarlAPI::SnarlStruct.malloc
    ss.cmd = SNARL_GET_VERSION
    version = SnarlAPI.send(ss)
    "#{version >> 16}.#{version & 0xffff}"
  end

  protected  
  # Return the internal snarl id 
  def id
    @ss.id
  end
    
  # exactly like the contructor -- this will create a new message, loosing
  # the original 
  def show(title,msg=" ", icon=nil, timeout=DEFAULT_TIMEOUT)
    @ss.title = SnarlAPI.to_cha(title)
    @ss.text = SnarlAPI.to_cha(msg)
    if icon
      icon = File.expand_path(icon)
      @ss.icon = SnarlAPI.to_cha(icon) if File.exist?(icon.to_s)
    end
    @ss.timeout = timeout
    @ss.cmd = SNARL_SHOW
    @ss.id = send
  end
  
  # Send the snarl structure, return the unfiltered result
  def send
    SnarlAPI.send(@ss)
  end
  
  # Send the snarl structure, return a true/false (interpreted from snarl)
  def send?
    !send.zero?
  end
end

