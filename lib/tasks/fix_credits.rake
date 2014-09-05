task :fix_credits => :environment do
  User.all.each do |u|
    if u.payments.where('reset_date IS NULL AND credit > 0 AND used_credit < credit').count == 0 && u.credit > 0
      puts "#{u.full_name} deberia tener 0 creditos"
      puts u.credit
      u.credit = 0
      u.save!
      puts "============================================="
    end
  end
end