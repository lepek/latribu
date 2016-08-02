class RemoveDeletedAtFromPayments < ActiveRecord::Migration
  def change
    deleted = Payment.delete(Payment.where('deleted_at IS NOT NULL').pluck(:id))
    puts "We have deleted #{deleted} records"
    remove_column :payments, :deleted_at, :datetime if deleted > 0
  end
end
