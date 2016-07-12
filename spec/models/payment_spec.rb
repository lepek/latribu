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

  describe '.save' do
    it 'cannot create a payment with the start credit date greater than the end credit date' do
      payment = Payment.new({
        month_year: Chronic.parse("1 this month"),
        credit: 10,
        credit_end_date: Chronic.parse("1 this month"),
        credit_start_date: Chronic.parse("1 next month"),
        amount: 200,
        user_id: user1.id
      })
      expect(payment.save).to be false
    end

    it 'creates a payment with the same start credit date and end credit date' do
      current_credits = user1.credit
      added_credits = 5
      payment = Payment.new({
          month_year: Chronic.parse("1 this month"),
          credit: added_credits,
          credit_end_date: Chronic.parse("today"),
          credit_start_date: Chronic.parse("today"),
          amount: 200,
          user_id: user1.id
      })
      expect(payment.save).to be true
      expect(user1.reload.credit).to eq(current_credits + added_credits)
    end

    it 'adds the new credits to the current credits' do
      current_credits = user1.credit
      added_credits = 5
      Payment.create({
          month_year: Chronic.parse("1 this month"),
          credit: added_credits,
          credit_start_date: Chronic.parse("1 this month"),
          credit_end_date: Chronic.parse("1 next month"),
          amount: 200,
          user_id: user1.id
      })
      expect(user1.reload.credit).to eq(current_credits + added_credits)
    end

    it 'cannot create a payment with negative credits' do
      payment = Payment.new({
          month_year: Chronic.parse("1 this month"),
          credit: -1,
          credit_start_date: Chronic.parse("1 next month"),
          credit_end_date: Chronic.parse("1 next month"),
          amount: 200,
          user_id: user1.id
      })
      expect(payment.save).to be false
    end

    it 'does not add the credits to the current credits if the start credit date is in the future' do
      current_credits = user1.credit
      Payment.create({
           month_year: Chronic.parse("1 this month"),
           credit: 5,
           credit_start_date: Chronic.parse("1 next month"),
           credit_end_date: Chronic.parse("1 next month"),
           amount: 200,
           user_id: user1.id
      })
      expect(user1.reload.credit).to eq(current_credits)
    end

    it 'does not add the credits to the current credits if the end credit date is in the past' do
      current_credits = user1.credit
      Payment.create({
           month_year: Chronic.parse("1 this month"),
           credit: 5,
           credit_start_date: Chronic.parse("one week ago"),
           credit_end_date: Chronic.parse("yesterday"),
           amount: 200,
           user_id: user1.id
      })
      expect(user1.reload.credit).to eq(current_credits)
    end

  end

  describe '.destroy' do
    it 'cannot destroy a payment with used credits' do
      payment = Payment.create({
        month_year: Chronic.parse("1 this month"),
        credit: 5,
        credit_start_date: Chronic.parse("1 this month"),
        credit_end_date: Chronic.parse("1 next month"),
        amount: 200,
        used_credit: 1,
        user_id: user1.id
      })
      current_payments = Payment.count
      expect(payment.destroy).to be false
      expect(Payment.count).to eq(current_payments)
    end

    it 'updates the credits when a payment is destroyed' do
      current_credits = user1.credit
      payment = Payment.create({
         month_year: Chronic.parse("1 this month"),
         credit: 5,
         credit_start_date: Chronic.parse("1 this month"),
         credit_end_date: Chronic.parse("1 next month"),
         amount: 200,
         user_id: user1.id
      })
      current_payments = Payment.count
      payment.destroy
      expect(Payment.count).to eq(current_payments - 1)
      expect(user1.reload.credit).to eq(current_credits)
    end
  end

  describe '.update' do
    it 'cannot update credits to be less than used credits' do
      used_credit = 3
      payment = Payment.create({
         month_year: Chronic.parse("1 this month"),
         credit: 5,
         credit_start_date: Chronic.parse("1 this month"),
         credit_end_date: Chronic.parse("1 next month"),
         amount: 200,
         used_credit: used_credit,
         user_id: user1.id
      })
      expect(payment.reload.update_attributes(credit: 2)).to be false
      expect(payment.reload.used_credit).to eq(used_credit)
    end

    it 'updates the credits when a payment is updated' do
      current_credits = user1.credit
      modified_credit = 3
      payment = Payment.create({
         month_year: Chronic.parse("1 this month"),
         credit: 5,
         credit_start_date: Chronic.parse("1 this month"),
         credit_end_date: Chronic.parse("1 next month"),
         amount: 200,
         user_id: user1.id
      })
      payment.reload.update_attributes(credit: modified_credit)
      expect(user1.reload.credit).to eq(current_credits + modified_credit)
    end

    it 'updates the credits when the end credit date of a resetted payment is modified to a valid date' do
      current_credits = user1.credit
      added_credits = 5
      payment = Payment.create({
         month_year: Chronic.parse("1 this month"),
         credit: added_credits,
         credit_start_date: Chronic.parse("one week ago"),
         credit_end_date: Chronic.parse("yesterday"),
         amount: 200,
         user_id: user1.id
      })
      expect(user1.reload.credit).to eq(current_credits)
      payment.reload.update_attributes(credit_start_date: Chronic.parse("1 this month"), credit_end_date: Chronic.parse("1 next month"))
      expect(user1.reload.credit).to eq(current_credits + added_credits)
    end

    it 'does not update the credits if the updated payment is resetted' do
      current_credits = user1.credit
      added_credits = 5
      payment = Payment.create({
         month_year: Chronic.parse("1 this month"),
         credit: added_credits,
         credit_start_date: Chronic.parse("1 this month"),
         credit_end_date: Chronic.parse("1 next month"),
         amount: 200,
         user_id: user1.id
      })
      expect(user1.reload.credit).to eq(current_credits + added_credits)
      payment.reload.update_attributes(credit_start_date: Chronic.parse("one week ago"), credit_end_date: Chronic.parse("yesterday"))
      expect(user1.reload.credit).to eq(current_credits)
    end
  end

end