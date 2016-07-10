namespace :credits do
  task :update => :environment do
    User.all.map { |u| u.update_credits! }
  end
end