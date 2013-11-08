class AddMonthToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :month, :string
  end
end
