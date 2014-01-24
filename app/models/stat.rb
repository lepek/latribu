class Stat < ActiveRecord::Base

  def self.credit_and_inscriptions
    credits = self.credit_stats
    inscriptions = self.inscription_stats
    stat = {}
    credits.each do |credit|
      month = Chronic.parse("1 #{credit.month} #{credit.year} 00:00:00")
      stat[month] = { :credits => credit.total_credit, :inscriptions => inscriptions[month] }
    end
    stat
  end

private

  def self.inscription_stats
    Inscription.group_by_month(:shift_date).order("month desc").count
  end

  def self.credit_stats
    Payment.where('month IS NOT NULL').select('SUM(credit) as total_credit, month, year').group(:month).group(:year)
  end

end
