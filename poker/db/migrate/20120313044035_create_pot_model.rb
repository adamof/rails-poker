class CreatePotModel < ActiveRecord::Migration
  def up
    create_table :pots do |t|

      # game
      t.integer   :amount,         :default => 0
      t.integer   :table_id
      t.string    :player_amounts
      t.integer   :highest_bet

      t.timestamps
    end
  end

  def down
    drop_talbe :pots
  end
end
