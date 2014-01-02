class AddYearToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :year, :integer, :default => 2014
  end
end
