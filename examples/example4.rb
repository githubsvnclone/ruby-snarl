require'snarl'

m = Snarl.new("Count down", "Here we go", nil, Snarl::NO_TIMEOUT)

10.downto(0) do |i|
  m.update("Count down", "T Minus #{i} and counting")
  sleep 1
end
m.update("*BOOM*")
m.hide

