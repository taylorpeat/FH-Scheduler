class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.integer :ranking
      t.integer :team_id
    end
  end
end
