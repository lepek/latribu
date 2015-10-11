require "rails_helper"

describe Payment, :type => :model do
  let (:user1) { FactoryGirl.create(:user_with_credit) }
  let (:user2) { FactoryGirl.create(:user_with_credit) }

  describe '.filter_by_dates' do
    it 'returns payments in date range' do
      Timecop.freeze(Time.zone.local(2015, 8, 10, 12, 0, 0)) do
        [user1, user2]
      end
      Timecop.freeze(Time.zone.local(2015, 9, 10, 12, 0, 0)) do
        FactoryGirl.create(:payment, user: user1)
      end
      Timecop.freeze(Time.zone.local(2015, 10, 10, 12, 0, 0)) do
        FactoryGirl.create(:payment, user: user2)
      end
      payments = Payment.filter_by_dates('10/08/2015', '10/09/2015')
      expect(payments.count).to eq(3)
      expect(payments).to include(*user1.payments)
      expect(payments).to include(user2.payments.order('month_year ASC').limit(1).first)
      expect(payments).to_not include(user2.payments.order('month_year DESC').limit(1).first)
    end

    it 'returns all payments' do
      Timecop.freeze(Time.zone.local(2015, 8, 10, 12, 0, 0)) do
        [user1, user2]
      end
      Timecop.freeze(Time.zone.local(2015, 9, 10, 12, 0, 0)) do
        FactoryGirl.create(:payment, user: user1)
      end
      Timecop.freeze(Time.zone.local(2015, 10, 10, 12, 0, 0)) do
        FactoryGirl.create(:payment, user: user2)
      end
      payments = Payment.filter_by_dates(nil, nil)
      expect(payments.count).to eq(4)
      expect(payments).to include(*user1.payments)
      expect(payments).to include(*user2.payments)
    end

  end
end