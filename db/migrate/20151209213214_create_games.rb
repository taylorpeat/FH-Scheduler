class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.datetime :date
    end
  end
end
