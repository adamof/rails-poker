# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
["Stefan@uci.edu", "Scott@uci.edu", "Masis@uci.edu", "Michael@uci.edu", 
  "Laurent@uci.edu", "Matan@uci.edu", "Tri@uci.edu", "Milin@uci.edu"].each do |p|
  Player.create!(:email => p, 
    :encrypted_password => "$2a$10$FKRtfcD./rtWcED/v4jxDOwvRs4YKnUa5CP6GW4z9eqIMkqxBidUy")
end

