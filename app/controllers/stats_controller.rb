class StatsController < ApplicationController
  authorize_resource

  def show
    @date = params[:id]
  end

  def month_inscriptions_chart
    @month = params[:id]
    @inscriptions = Inscription.where(
        :shift_date => Chronic.parse("#{@month} 00:00:00")..Chronic.parse("#{@month}").end_of_month
    ).group("DATE_FORMAT(shift_date, '%W%H%i')").order("count(id) DESC").pluck("shift_date, count(id)")
    @inscriptions.map! { |stat| [I18n.l(stat.first, :format => '%A %H:%M hs.'), stat[1]] }
    render json: @inscriptions
  end
end

