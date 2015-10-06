class RemoveMonthAndYearFromPayments < ActiveRecord::Migration
  def up
    remove_column :payments, :month
    remove_column :payments, :year
  end

  def down
    add_column :payments, :month, :string
    add_column :payments, :year, :integer, default: 2014
  end
end
