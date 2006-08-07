require'snarl'

m = Snarl.new("Count down", "Here we go", 0)

10.downto(0) do |i|
  m.update("Count down", "T Minus #{i} and counting")
  sleep 1
end
m.update("*BOOM*")
m.hide

