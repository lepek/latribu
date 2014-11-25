class AddCertificateAndEnableToUsers < ActiveRecord::Migration
  def change
    add_column :users, :certificate, :boolean, :default => false
    add_column :users, :enable, :boolean, :default => true
  end
end
