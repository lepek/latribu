task :fix_shifts => :environment do
  Chronic.time_class = Time.zone
  users = []
  Shift.all.each do |shift|
    inscriptions = shift.inscriptions.where("shift_date LIKE '#{Time.zone.now.strftime('%Y-%m-%d')}%'")
    inscriptions.each do |insc|
      insc.shift_date = Chronic.parse("#{Time.zone.now.strftime('%Y-%m-%d')} #{shift.start_time.strftime('%H:%M:%S')}")
      puts "#{insc.user.first_name} #{insc.user.last_name}: #{insc.shift_date}"
      users << insc.user_id
      insc.save!
    end
  end
  repeats = users.length - users.uniq.length
  puts repeats
end