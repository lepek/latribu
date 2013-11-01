class CreateInscriptions < ActiveRecord::Migration
  def change
    create_table :inscriptions do |t|
      t.datetime :shift_date
      t.timestamps
    end
  end
end
