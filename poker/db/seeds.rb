# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
["Stefan", "Scott", "Masis", "Michael", "Laurent", "Matan", "Tri", "Milin"].each do |os|
  Player.find_or_create_by_email os
end

Table.create!(:blind_amount => 10, :button => 1, :players => Player.all, 
  :cards_on_table => ["5S", "3H", "KS", "QC", "JH"], 
  :cards_in_deck => ["3S", "3S", "KC", "QS", "JS"])
Pot.create(:amount => 300, :table => Table.last)
