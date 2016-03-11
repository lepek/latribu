class StatsController < ApplicationController

  def index
    @order = params[:order]
    @date = params[:date]
    render :show and return if @date.present?

    Stat.generate
    respond_to do |format|
      format.html
      format.json { render json: StatDatatable.new(view_context) }
    end
  end

  def month_inscriptions_chart
    @month = params[:date]
    @order = params[:order]

    @days = Inscription.where(
        :shift_date => Chronic.parse("#{@month} 00:00:00")..Chronic.parse("#{@month}").end_of_month
    ).group("weekday(shift_date)").order("weekday(shift_date) ASC").pluck("count(distinct(DATE_FORMAT(shift_date, '%W%d')))")

    @inscriptions = Inscription.where(
        :shift_date => Chronic.parse("#{@month} 00:00:00")..Chronic.parse("#{@month}").end_of_month
    ).group("DATE_FORMAT(shift_date, '%W%H%i')").order("shift_date ASC").pluck("shift_date, count(id), weekday(shift_date)")

    @inscriptions.map! { |stat| [I18n.l(stat.first, :format => '%A %H:%M hs.'), (stat[1].to_f/@days[stat[2]]).round(2) ] }

    if @order == 'asc'
      @inscriptions.sort_by! { |i| i[1] }
    elsif @order == 'desc' || @order.blank?
      @inscriptions.sort_by! { |i| i[1] }.reverse!
    end

    render json: @inscriptions
  end

end

