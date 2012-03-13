class CreatePlayerModel < ActiveRecord::Migration
  def up
    create_table :players do |t|
      
      # devise
      ## Database authenticatable
      t.string    :email,              :null => false, :default => ""
      t.string    :encrypted_password, :null => false, :default => "" 

      # game
      t.string    :name
      t.string    :card_1
      t.string    :card_2
      t.string    :token
      t.datetime  :left_game_at
      t.integer   :money,   :default => 0
      t.boolean   :folded,  :default => false
      t.string    :last_action

      # belongs to
      t.integer   :table_id
      t.integer   :tournament_id

      t.timestamps
    end
    add_index :players, :email,     :unique => true
  end

  def down
    drop_table :players
  end
end
