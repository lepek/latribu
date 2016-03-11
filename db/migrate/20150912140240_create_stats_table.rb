class CreateStatsTable < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.date :month_year
      t.integer :inscriptions
      t.integer :credits
      t.timestamps
    end
  end
end
