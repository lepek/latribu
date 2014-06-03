class AddFieldsToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :used_credit, :integer, :default => 0
    add_column :payments, :reset_date, :datetime
    add_column :payments, :month_year, :date
  end
end
