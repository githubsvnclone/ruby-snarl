require 'dl/import'
require 'dl/struct'
require 'dl/win32'

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
    #extern "HWND CreateWindowEx(DWORD, LPCSTR, LPCSTR, DWORD, int, int, HWND, HMENU, HINSTANCE, LPVOID)"
    
    CreateWindow = Win32API.new("user32", "CreateWindowExA", ['L', 'p', 'p', 'l', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'p'], 'L')
    DestroyWindow = Win32API.new("user32", "DestroyWindow", ['L'], 'L')
    
    #WIN32API
    HWND_MESSAGE = 0x84
    WM_USER = 0x400
    
    #Global Event Ids
    SNARL_GLOBAL_MSG = "SnarlGlobalEvent"
    SNARL_LAUNCHED = 1
    SNARL_QUIT = 2
    SNARL_ASK_APPLET_VER = 3 #introduced in V36
    SNARL_SHOW_APP_UP = 4 #introduced in V37
    
    #Message Event Ids
    SNARL_NOTIFICATION_CLICKED = 32
    SNARL_NOTIFICATION_TIMED_OUT = 33
    SNARL_NOTIFICATION_ACK = 34
    SNARL_NOTIFICATION_CANCLED = SNARL_NOTIFICATION_CLICKED #yes that's right.
    
    #Snarl Commands
    SNARL_SHOW = 1
    SNARL_HIDE = 2
    SNARL_UPDATE = 3
    SNARL_IS_VISIBLE = 4
    SNARL_GET_VERSION = 5
    SNARL_REGISTER_CONFIG_WINDOW = 6
    SNARL_REVOKE_CONFIG_WINDOW = 7
    SNARL_REGISTER_ALERT = 8
    SNARL_REVOKE_ALERT = 9
    SNARL_REGISTER_CONFIG_WINDOW_2 = 10
    SNARL_GET_VERSION_EX = 11
    SNARL_SET_TIMEOUT = 12
    SNARL_EX_SHOW = 32
    SNARL_TEXT_LENGTH = 1024
    WM_COPYDATA = 0x4a
    
    BaseSnarlStruct = [
      "int cmd",
      "long id",
      "long timeout",
      "long data2",
      "char title[#{SNARL_TEXT_LENGTH}]",
      "char text[#{SNARL_TEXT_LENGTH}]", 
      "char icon[#{SNARL_TEXT_LENGTH}]",                     
    ]
  
    SnarlStruct = struct BaseSnarlStruct
    
    SnarlStructEx = struct BaseSnarlStruct + [
    	"char snarl_class[#{SNARL_TEXT_LENGTH}]",
    	"char extra[#{SNARL_TEXT_LENGTH}]",
    	"char extra2[#{SNARL_TEXT_LENGTH}]",
    	"int reserved1",
    	"int reserved2"]
  
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
  NO_TIMEOUT = 0
  
  # Create a new snarl message, the only thing you need to send is a title
  # note that if you decide to send an icon, you must provide the complete
  # path. The timeout file has a default value (DEFAULT_TIMEOUT -> 3 seconds)
  # but can be set to Snarl::NO_TIMEOUT, to force a manual acknowledgement
  # of the notification.
  def initialize(title, options = {:snarl_class => nil, :msg => " ", :timeout => DEFAULT_TIMEOUT, :icon => nil, :extra => nil})
  	
  	if options[:extra] && options[:snarl_class].nil? then raise ArgumentError.new("Must specificy a snarl_class to use sound notifications") end
  	
  	if options[:snarl_class].nil? then
    	@ss = SnarlStruct.malloc
    	show(title, options)
	else
		@ss = SnarlStructEx.malloc
		show(title, options)
	end
  end
      
  # a quick and easy method to create a new message, when you don't care
  # to access it again.
  # Note that if you decide to send an icon, you must provide the complete
  # path. The timeout file has a default value (DEFAULT_TIMEOUT -> 3 seconds)
  # but can be set to Snarl::NO_TIMEOUT, to force a manual acknowledgement
  # of the notification.
  def self.show_message(title, options = {:snarl_class => nil, :msg => " ", :timeout => DEFAULT_TIMEOUT, :icon => nil, :extra => nil})
    Snarl.new(title, options)
  end

  # Update an existing message, it will return true/false depending upon
  # success (it will fail if the message has already timed out or been 
  # dismissed)
  # Note that if you decide to send an icon, you must provide the complete
  # path. The timeout file has a default value (DEFAULT_TIMEOUT -> 3 seconds)
  # but can be set to Snarl::NO_TIMEOUT, to force a manual acknowledgement
  # of the notification.
  def update(title,msg=" ",icon=nil, timeout=DEFAULT_TIMEOUT)
    @ss.cmd = SNARL_UPDATE
    @ss.title = SnarlAPI.to_cha(title)
    @ss.text = SnarlAPI.to_cha(msg)
    if icon
      icon = File.expand_path(icon)
      @ss.icon = SnarlAPI.to_cha(icon) if File.exist?(icon.to_s)
    end
    @ss.timeout = timeout
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
  
  # Return the current build number of snarl (not the snarl gem)
  # If zero will call the original version.
  def self.versionex
  	ssx = SnarlAPI::SnarlStructEx.malloc
  	ssx.cmd = SNARL_GET_VERSION_EX
  	versionex = SnarlAPI.send(ssx);
  	if versionex == 0 then
  		self.version
  	else
  		"#{versionex}"
  	end
  end

  protected  
  # Return the internal snarl id 
  def id
    @ss.id
  end
  
  #Register an application, and optionally an icon for it 
  #We return the message_only window we create.
  #NOTE: We do not support config windows.
  def self.registerconfig(title, icon=nil)
  	ss = SnarlAPI::SnarlStruct.malloc
  	ss.title = SnarlAPI.to_cha(title)
  	ss.cmd = SNARL_REGISTER_CONFIG_WINDOW
  	ss.id = WM_USER
  	if not icon.nil? then
  		ss.icon = SnarlAPI.to_cha(icon) if File.exist?(icon)
  		ss.cmd = SNARL_REGISTER_CONFIG_WINDOW_2
  	end
  	
  	win = SnarlAPI::CreateWindow.call(0, "Message", 0, 0 ,0 ,0 ,0 ,0 ,HWND_MESSAGE, 0, 0, 0)
  	ss.data2 = win
  	SnarlAPI.send(ss)
  	win
  end
  
  #Unregister application, passing in the value returned from registerconfig
  def self.revokeconfig(hWnd)
  	ss = SnarlAPI::SnarlStruct.malloc
  	ss.data2 = hWnd
  	ss.cmd = SNARL_REVOKE_CONFIG_WINDOW
  	SnarlAPI.send(ss)
  	Snarl::DestroyWindow.call(hWnd)
  end
  
  #Register an alert for [app] using the name [text]
  def self.registeralert(app, text)
  	ss = SnarlAPI::SnarlStruct.malloc
  	ss.title = SnarlAPI.to_cha(app)
  	ss.text = SnarlAPI.to_cha(text)
  	ss.cmd = SNARL_REGSITER_ALERT
  	SnarlAPI.send(ss)
  end
  
  
  # exactly like the contructor -- this will create a new message, loosing
  # the original 
  def show(title, options = {:snarl_class => nil, :msg => " ", :timeout => DEFAULT_TIMEOUT, :icon => nil, :extra => nil})
  	
  	options[:timeout] = DEFAULT_TIMEOUT if options[:timeout].nil?
  	options[:msg] = " " if options[:msg].nil?
  	
  	if options[:snarl_class].nil? then 
  		@ss.cmd = SNARL_SHOW 
  	else 
  		@ss.cmd = SNARL_EX_SHOW 
  		@ss.snarl_class = options[:snarl_class]
  	end
    
    @ss.title = SnarlAPI.to_cha(title)
    @ss.text = SnarlAPI.to_cha(options[:msg])
        
    if options[:icon]
      #Expand Path in Cygwin causes the cygwin path to be returned (ie /cygdrive/c/blah) this is not what we want
      #as Snarl is running in windows and expects a C:\blah path.  We've told them to use an absolute path anyway.
      #options[:icon] = File.expand_path(options[:icon])
      @ss.icon = SnarlAPI.to_cha(options[:icon]) if File.exist?(options[:icon].to_s)
    end
    
    if options[:extra]
    	unless options[:extra][0] == 43
    		#options[:extra] = File.expand_path(options[:extra]) 
    		@ss.extra = SnarlAPI.to_cha(options[:extra]) if File.exist?(options[:extra].to_s)
    	else
    		@ss.extra = SnarlAPI.to_cha(options[:extra])
    	end
    end
    
    @ss.timeout = options[:timeout]
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

