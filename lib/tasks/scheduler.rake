desc "This task is called by the Heroku scheduler add-on"
task :reset_credits => :environment do
  Chronic.time_class = Time.zone
  User.reset_credits(:hot)
end