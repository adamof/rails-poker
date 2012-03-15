# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Table.create!(:blind_amount => 10, :button => 1, :players => Player.all, 
  :cards_on_table => ["5S", "3H", "KS", "QC", "JH"], 
  :cards_in_deck => ["3S", "3S", "KC", "QS", "JS"])

Pot.create(:amount => 300, :table => Table.last)

["Stefan@uci.edu", "Scott@uci.edu", "Masis@uci.edu", "Michael@uci.edu", 
  "Laurent@uci.edu", "Matan@uci.edu", "Tri@uci.edu", "Milin@uci.edu"].each do |p|
  Player.create!(:email => p, 
    :encrypted_password => "$2a$10$FKRtfcD./rtWcED/v4jxDOwvRs4YKnUa5CP6GW4z9eqIMkqxBidUy",
    :pots => Pot.all, :table => Table.last)
end

