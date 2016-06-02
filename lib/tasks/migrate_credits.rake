namespace :migrate do
  task :credits => :environment do
    Payment.transaction do
      Payment.with_deleted.where("month_year IS NOT NULL").find_each do |payment|
        payment.credit_start_date = payment.month_year
        payment.credit_end_date = payment.month_year + 1.month + 4.days
        payment.save!(validate: false)
      end
    end
  end
end

