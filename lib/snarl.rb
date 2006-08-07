require 'dl/import'
require 'dl/struct'

class Snarl
  
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
  
    def self.to_cha(str)
      result = str.split(/(.)/).map { |ch| ch[0] }.compact
      result + Array.new(SNARL_TEXT_LENGTH - result.size, 0)
    end
    
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
  
  def initialize(title, msg=" ", icon=nil, timeout=10)
    @ss = SnarlStruct.malloc
    show(title, msg, icon, timeout)
  end
      
  def self.show_message(title, msg=" ", icon=nil, timeout=10)
    Snarl.new(title, msg, icon, timeout).id
  end

  def show(title,msg=" ", icon=nil, timeout=10)
    @ss.title = SnarlAPI.to_cha(title)
    @ss.text = SnarlAPI.to_cha(msg)
    icon = File.expand_path(icon)
    @ss.icon = SnarlAPI.to_cha(icon) if icon && File.exist?(icon)
    @ss.timeout = timeout
    @ss.cmd = SNARL_SHOW
    @ss.id = send
  end
  
  def update(title,msg=" ",icon=nil)
    @ss.cmd = SNARL_UPDATE
    @ss.title = SnarlAPI.to_cha(title)
    @ss.text = SnarlAPI.to_cha(msg)
    @ss.icon = SnarlAPI.to_cha(icon) if icon
    send?    
  end
  
  def hide
    @ss.cmd = SNARL_HIDE
    send?
  end
  
  def id
    @ss.id
  end
    
  def visible?
    @ss.cmd = SNARL_IS_VISIBLE
    send?
  end
  
  def self.version
    ss = SnarlAPI::SnarlStruct.malloc
    ss.cmd = SNARL_GET_VERSION
    version = SnarlAPI.send(ss)
    "#{version >> 16}.#{version & 0xffff}"
  end
  
  private
  def send
    SnarlAPI.send(@ss)
  end
  
  def send?
    !send.zero?
  end
end

