class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.integer :credit, null: false
      t.integer :used_credit, default: 0
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.references :user, index: true, null: false
      t.boolean :expired, default: false
      t.timestamps null: false
    end
  end
end
