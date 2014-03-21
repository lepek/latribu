class AddLastResetDateFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_reset_date, :datetime, :default => '2014-03-05 23:59:59'
  end
end
