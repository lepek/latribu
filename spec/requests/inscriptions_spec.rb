require "rails_helper"

describe 'Inscriptions', :type => :request do
  context "when logged in as user with credit" do
    let(:shift_attributes) { { start_time: '10:00', end_time: '11:00' } }
    let!(:shift_monday) { FactoryGirl.create(:shift, shift_attributes.merge!(week_day: 2)) }
    let!(:shift_tuesday) { FactoryGirl.create(:shift, shift_attributes.merge!(week_day: 3)) }
    let!(:shift_wednesday) { FactoryGirl.create(:shift, shift_attributes.merge!(week_day: 4)) }
    let!(:shift_thursday) { FactoryGirl.create(:shift, shift_attributes.merge!(week_day: 5)) }
    let!(:shift_friday) { FactoryGirl.create(:shift, shift_attributes.merge!(week_day: 6)) }
    let!(:shift_saturday) { FactoryGirl.create(:shift, shift_attributes.merge!(week_day: 7)) }
    let(:user_with_credit) { FactoryGirl.create(:user_with_credit) }
    let(:user_without_credit) { FactoryGirl.create(:user) }

    before(:each) do
      login_as user_with_credit
    end

  end

end