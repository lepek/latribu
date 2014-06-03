class Stat < ActiveRecord::Base

  def self.credit_and_inscriptions
    credits = self.credit_stats || {}
    inscriptions = self.inscription_stats
    stat = {}
    time = inscriptions.empty? ? '00:00:00' : inscriptions.first.first.strftime('%H:%M:%S')
    credits.each do |credit|
      month = Chronic.parse("#{credit.month_year} #{time}")
      stat[month] = { :credits => credit.total_credit, :inscriptions => inscriptions[month] }
    end
    stat
  end

private

  def self.inscription_stats
    Inscription.group_by_month(:shift_date).order("month desc").count
  end

  def self.credit_stats
    Payment.where('month_year IS NOT NULL').select('SUM(credit) as total_credit, month_year').group(:month_year)
  end

end
