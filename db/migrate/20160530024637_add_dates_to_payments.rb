class AddDatesToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :credit_start_date, :date, null: false
    add_column :payments, :credit_end_date, :date, null: false
  end
end
