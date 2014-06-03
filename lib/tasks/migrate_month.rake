task :migrate_month => :environment do
  Chronic.time_class = Time.zone
  reset_date = Chronic.parse('2014-05-10 23:21:00')
  Payment.delete_all("month IS NULL or month = ''")
  Payment.all.each do |p|
    p.month_year = Chronic.parse("1 #{p.month} #{p.year}")
    unless ['june','may'].include?(p.month)
      p.reset_date = reset_date
    else
      p.reset_date = nil
    end
    p.save!
  end

  User.all.each do |u|
    total_credit = u.payments.where('reset_date IS NULL').map(&:credit).sum
    credit = total_credit - u.credit
    payments = u.payments.where('reset_date IS NULL')
    payments.each do |p|
      p.used_credit = credit if credit < p.credit
      p.used_credit = p.credit if credit >= p.credit
      credit = credit - p.credit
      p.save!
      break if credit <= 0
    end
  end

end