class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :message
      t.date :start_date
      t.date :end_date
      t.timestamps null: false
    end
  end
end
