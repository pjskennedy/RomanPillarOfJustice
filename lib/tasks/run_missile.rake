require 'missile/client'

task run_missile: :environment do
  m = Missile::Client.new
  m.zero!
  loop do
    m.shoot_targets
    sleep 5
  end
end
