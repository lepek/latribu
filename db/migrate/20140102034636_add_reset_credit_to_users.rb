class AddResetCreditToUsers < ActiveRecord::Migration
  def change
    add_column :users, :reset_credit, :boolean, :default => true
  end
end
