desc "This task is called by the Heroku scheduler add-on"
task :reset_credits => :environment do
  Chronic.time_class = Time.zone
  if defined?(Rails) && (Rails.env == 'development')
    Rails.logger = Logger.new(STDOUT)
  end
  logger = Rails.logger
  User.clients.each do |user|
    if user.credit > 0 && user.reset_credit
      credits_unused = user.last_month_credits - user.last_month_credits_used
      if credits_unused > 0
        logger.info user.id.to_s + " - " + user.full_name
        logger.info "Creditos del ultimo mes: #{user.last_month_credits}"
        logger.info "Creditos usados #{user.last_month_credits_used}"
        logger.info "Creditos no usado: #{credits_unused}"
        logger.info "Credito actual: #{user.credit}"
        logger.info "Credito modificado: #{user.credit - credits_unused}"
        logger.info "====================================================="
        user.credit -= credits_unused
        user.save!
      end
    end
  end
end