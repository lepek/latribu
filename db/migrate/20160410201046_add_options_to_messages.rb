class AddOptionsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :show_all, :boolean, default: true
    add_column :messages, :show_no_certificate, :boolean, default: false
    add_column :messages, :show_credit_less, :integer, default: -1
  end
end
