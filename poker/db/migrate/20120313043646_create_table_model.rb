class CreateTableModel < ActiveRecord::Migration
  def up
    create_table :tables do |t|

      # game
      t.text      :cards_on_table
      t.text      :cards_in_deck
      t.integer   :button,          :default => 0
      t.integer   :blind_amount
      t.integer   :tournament_id
      t.integer   :hands_played,    :default => 0
      t.integer   :player_turn,     :default => 0

      t.timestamps
    end
  end

  def down
    drop_table :pots
  end
end
