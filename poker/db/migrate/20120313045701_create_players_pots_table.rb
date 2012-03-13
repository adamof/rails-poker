class CreatePlayersPotsTable < ActiveRecord::Migration
  def self.up
    create_table :players_pots, :id => false do |t|
        t.references :player
        t.references :pot
    end
    add_index :players_pots, [:player_id, :pot_id]
    add_index :players_pots, [:pot_id, :player_id]
  end

  def self.down
    drop_table :players_pots
  end
end
