namespace :migrate do
  task :credits => :environment do
    Payment.where('credit != 0').each do |payment|
      agg = Credit.find_by(start_date: payment.month_year, end_date: payment.month_year + 1.month + 4.days, expired: payment.reset_date.present?, user_id: payment.user_id)
      credit = agg.nil? ? Credit.new : agg
      credit.credit = credit.credit.to_i + payment.credit
      credit.used_credit = credit.used_credit.to_i + payment.used_credit
      credit.expired = payment.reset_date.present?
      credit.start_date = payment.month_year
      credit.end_date = payment.month_year + 1.month + 4.days
      credit.user_id = payment.user_id
      credit.save!
    end
  end
end

