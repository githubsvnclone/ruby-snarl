require 'snarl'

puts "Snarl Version: #{Snarl.version}"

10.downto(1) do |i|
  Snarl.show_message("Message", "Counting down #{i}", i)
end

sleep 11

10.times do |i|
  Snarl.show_message("Message", "Counting down #{i+1}", i+1)
end

