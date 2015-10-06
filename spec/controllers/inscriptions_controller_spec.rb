require 'rails_helper'

describe InscriptionsController, :type => :controller do

  describe "GET #index" do

    context "when logged in as user" do
      before(:each) do
        @user = FactoryGirl.create(:user_with_credit)
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in @user
      end

      it "loads the inscriptions page" do
        expect(response).to be_success
      end

      it "loads the shifts" do
        base_date =  Chronic.parse("now")
        week_day = base_date.strftime('%w').to_i + 1
        start_time = base_date.strftime('%H:%M')
        end_time = (base_date + 1.hour).strftime('%H:%M')

        shifts = []
        shifts << FactoryGirl.create(:shift, week_day: week_day, start_time: start_time, end_time: end_time)

        get :index, format: 'json', start: base_date.strftime('%Y-%m-%d')

        results = JSON.parse(response.body)
        expect(results.count).to eq(shifts.count)
        expect(Time.zone.parse(results.first['start']).strftime('%Y-%m-%d %H:%M')).to eq(base_date.strftime('%Y-%m-%d %H:%M'))
      end
    end

  end

end
