class StatsController < ApplicationController
  authorize_resource

  def show
    @date = params[:id]
  end

  def month_inscriptions_chart
    @month = params[:id]
    @days = Inscription.where(
        :shift_date => Chronic.parse("#{@month} 00:00:00")..Chronic.parse("#{@month}").end_of_month
    ).group("weekday(shift_date)").order("weekday(shift_date) ASC").pluck("count(distinct(DATE_FORMAT(shift_date, '%W%d')))")

    @inscriptions = Inscription.where(
        :shift_date => Chronic.parse("#{@month} 00:00:00")..Chronic.parse("#{@month}").end_of_month
    ).group("DATE_FORMAT(shift_date, '%W%H%i')").order("shift_date ASC").pluck("shift_date, count(id), weekday(shift_date)")
    @inscriptions.map! { |stat| [I18n.l(stat.first, :format => '%A %H:%M hs.'), (stat[1].to_f/@days[stat[2]]).round(2) ] }
    render json: @inscriptions
  end
end

