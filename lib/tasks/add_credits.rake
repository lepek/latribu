task :add_credits => :environment do
  Chronic.time_class = Time.zone
  credit = 5
  User.clients.each do |user|
    if user.credit < 5
      Payment.create(
        :user_id => user.id,
        :amount => 0,
        :credit => credit - user.credit,
        :month => 'april',
        :year => '2014'
      )
    end
  end
end