require 'leaderboard_validator'

Thread.new do
  puts "Validating leaders"
  while true do
    Leader.validate_all
    sleep(3.minutes)
  end
end
