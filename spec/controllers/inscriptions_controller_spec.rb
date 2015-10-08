require 'rails_helper'

describe InscriptionsController, :type => :controller do

  let(:user_with_credit) { FactoryGirl.create(:user_with_credit) }
  let(:shift) { FactoryGirl.create(:shift) }

  context "when logged in as a user" do
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user_with_credit
    end

    describe "GET #index" do

      it "loads the inscriptions page" do
        get :index
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

    describe "POST #create" do
      it "creates a new inscription" do
        old_user_credit = subject.current_user.credit
        Timecop.freeze(shift.next_fixed_shift - shift.open_inscription.hour + 1.minute) do
          expect { post :create, format: 'json', id: shift.id }.to change(Inscription, :count).by(1)
          expect(response).to have_http_status(:created)
          expect(shift.inscriptions.where(shift_date: shift.next_fixed_shift, user_id: subject.current_user.id).first.user).to eq(user_with_credit)
          expect(subject.current_user.credit).to eq(old_user_credit - 1)
        end
      end

      it "does not create a new inscription" do
        old_user_credit = subject.current_user.credit
        Timecop.freeze(shift.next_fixed_shift - shift.open_inscription.hour - 1.minute) do
          expect(shift.status).to eq(Shift::STATUS[:close])
          expect { post :create, format: 'json', id: shift.id }.to_not change(Inscription, :count)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(shift.inscriptions.where(shift_date: shift.next_fixed_shift, user_id: subject.current_user.id)).to be_empty
          expect(subject.current_user.credit).to eq(old_user_credit)
        end
      end
    end

    describe "DELETE #destroy" do
      it "removes the user inscription" do
        old_user_credit = subject.current_user.credit
        Timecop.freeze(shift.next_fixed_shift - shift.open_inscription.hour + 1.minute) do
          shift.enroll_next_shift(subject.current_user)
        end
        Timecop.freeze(shift.next_fixed_shift - shift.open_inscription.hour + 15.minute) do
          expect { delete :destroy, format: 'json', id: shift.id }.to change(Inscription, :count).by(-1)
          expect(response).to have_http_status(:ok)
          expect(shift.inscriptions.where(shift_date: shift.next_fixed_shift, user_id: subject.current_user.id)).to be_empty
          expect(subject.current_user.credit).to eq(old_user_credit)
        end
      end

      it "does not remove inscription if it is too late" do
        old_user_credit = subject.current_user.credit
        Timecop.freeze(shift.next_fixed_shift - shift.open_inscription.hour + 1.minute) do
          shift.enroll_next_shift(subject.current_user)
        end
        Timecop.freeze(shift.next_fixed_shift - shift.close_inscription.hour + 1.minute) do
          expect { delete :destroy, format: 'json', id: shift.id }.to_not change(Inscription, :count)
          expect(response).to have_http_status(:unprocessable_entity)
          expect(shift.inscriptions.where(shift_date: shift.next_fixed_shift, user_id: subject.current_user.id).first.user).to eq(user_with_credit)
          expect(subject.current_user.credit).to eq(old_user_credit - 1)
        end
      end
    end

    describe "POST #attended" do
      it "raises an exception if the user is not an admin" do
        Timecop.freeze(shift.next_fixed_shift - shift.open_inscription.hour + 1.minute) do
          post :create, format: 'json', id: shift.id
          inscription = shift.inscriptions.where(shift_date: shift.next_fixed_shift, user_id: subject.current_user.id).first
          post :attended, format: 'json', id: inscription.id
          expect(response).to have_http_status(:unauthorized)
          expect(inscription.attended).to be(false)
        end
      end
    end


  end

end
