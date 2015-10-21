class Stat < ActiveRecord::Base

  def self.generate
    credits = self.credit_stats || {}
    inscriptions = self.inscription_stats
    credits.each do |credit|
      stat = Stat.find_or_initialize_by(month_year: credit.month_year) do |stat|
        stat.credits = credit.total_credit
        stat.inscriptions = inscriptions[credit.month_year.strftime('%Y%m').to_i]
      end
      stat.save!
    end
  end

  private

  # Compatible with MySQL only
  # @return Example: {201311=>7, 201312=>412, 201401=>1140, 201402=>1393, 201403=>1289, 201404=>1560, 201405=>1149, 201406=>875, 201407=>819, 201408=>56}
  def self.inscription_stats
    Inscription.group("EXTRACT(YEAR_MONTH FROM shift_date)").count

    # With group_date gem, for postgresql. With MySQL the default timezone must be utc and I cannot change it without migrating the times in the DB
    #Inscription.group_by_month(:shift_date).order("month desc").count
  end

  def self.credit_stats
    Payment.where('month_year IS NOT NULL').select('SUM(credit) as total_credit, month_year').group(:month_year)

  end

end
