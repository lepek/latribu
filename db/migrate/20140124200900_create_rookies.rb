class CreateRookies < ActiveRecord::Migration
  def change
    create_table :rookies do |t|
      t.datetime :shift_date
      t.timestamps
      t.string :full_name
      t.string :phone
      t.string :email
      t.string :notes
    end
  end
end
