require 'snarl'

clock_message = Snarl.new('Time', Time.now.to_s, nil, Snarl::NO_TIMEOUT)
while clock_message.visible?
  clock_message.update('Time', Time.now.to_s)
  sleep 0.75
end


