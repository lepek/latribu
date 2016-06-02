require "rails_helper"

describe User, :type => :model do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:user) { FactoryGirl.create(:user) }
  let(:user_with_credit) { FactoryGirl.create(:user_with_credit) }
  let(:shift) { FactoryGirl.create(:shift) }

  context "when user is an admin" do
    describe '#admin?' do
      it 'returns true for admin user' do
        expect(admin.admin?).to be(true)
      end
    end

    describe '.reset_credits' do
      it 'raises an exception' do
        expect { User.reset_credits('2015/13/12 00:00') }.to raise_error(ArgumentError)
      end

      it 'does not raise an exception' do
        [user, user_with_credit, user_with_credit]
        expect { User.reset_credits('2015/12/12 00:00') }.to_not raise_error(Exception)
      end
    end

    describe '.to_reset' do
      it 'returns only users to reset' do
        reset_user = user
        FactoryGirl.create(:user, reset_credit: false)
        expect(User.to_reset.count).to eq(1)
        expect(User.to_reset).to include(reset_user)
      end
    end

    describe '.clients' do
      it 'returns only clients' do
        [admin, user]
        expect(User.clients.count).to eq(1)
        expect(User.clients).to include(user)
      end
    end

  end

  context "when user is a client" do

    describe '#pending_messages' do
      let!(:message_for_all) { FactoryGirl.create(:message_for_all) }
      let!(:message_for_no_certificate) { FactoryGirl.create(:message_for_no_certificate) }
      let!(:message_for_credit_less) { FactoryGirl.create(:message_for_credit_less) }
      let!(:message_yesterday) { FactoryGirl.create(:message_yesterday) }
      let(:user_with_five_credits) { FactoryGirl.create(:user_with_five_credits) }
      let(:user_with_certificate) { FactoryGirl.create(:user_with_certificate) }

      it 'returns messages for all and for no certificate' do
        expect(user_with_five_credits.pending_messages).to match_array([message_for_all.message, message_for_no_certificate.message])
      end

      it 'returns messages for all, for no certificate and for less credit' do
        expect(user.pending_messages).to match_array([message_for_all.message, message_for_no_certificate.message, message_for_credit_less.message])
      end

      it 'returns messages for all and for less credit' do
        expect(user_with_certificate.pending_messages).to match_array([message_for_all.message, message_for_credit_less.message])
      end

    end

    describe '#full_name' do
      it 'returns the full name' do
        expect(user.full_name).to eq('Doe, John')
      end
    end

    describe '#admin?' do
      it 'returns false for non admin user' do
        expect(user.admin?).to be(false)
      end
    end

    describe '#name' do
      it 'returns a label name' do
        expect(user.name).to eq("#{user.first_name} #{user.last_name} (#{user.email})")
      end
    end

    describe '#reset_credit' do
      it 'returns true' do
        expect(user.reset_credit?).to be(true)
      end
    end

    describe '#credit' do
      it 'adds new credit' do
        FactoryGirl.create(:payment, user: user, credit: 10)
        expect(user.credit).to eq(10)
      end

      it 'does not add new credit if date_to is in the future' do
        FactoryGirl.create(:payment, user: user, credit: 10)
        expect(user.credit).to eq(10)
        FactoryGirl.create(:payment,
                           user: user,
                           credit_start_date: Chronic.parse('tomorrow'),
                           credit_end_date: Chronic.parse('next week'),
                           credit: 5
        )
        expect(user.credit).to eq(10)
      end

      it 'does not add new credit if date_from is in the past' do
        FactoryGirl.create(:payment, user: user, credit: 10)
        expect(user.credit).to eq(10)
        FactoryGirl.create(:payment,
                           user: user,
                           credit_start_date: Chronic.parse('last week'),
                           credit_end_date: Chronic.parse('yesterday'),
                           credit: 5
        )
        expect(user.credit).to eq(10)
      end

      it 'adds an already added credit when the time comes' do
        FactoryGirl.create(:payment, user: user, credit: 10)
        expect(user.credit).to eq(10)
        FactoryGirl.create(:payment,
                           user: user,
                           credit_start_date: Chronic.parse('tomorrow'),
                           credit_end_date: Chronic.parse('next week'),
                           credit: 5
        )
        Timecop.freeze(Chronic.parse('tomorrow')) do
          user.update_credits!
          expect(user.credit).to eq(15)
        end
      end

      it 'returns 0 credits if there is no valid credits for the date' do
        Timecop.freeze(shift.next_fixed_shift - 1.hour) do

          FactoryGirl.create(:payment, user: user, credit: 1)
          FactoryGirl.create(:payment,
                             user: user,
                             credit_start_date: Chronic.parse('tomorrow'),
                             credit_end_date: Chronic.parse('next week'),
                             credit: 5
          )
          shift.enroll_next_shift(user)
          expect(user.reload.credit).to eq(0)
        end
      end
    end

    describe '#calculate_future_credit' do
      it 'returns 0 future credits' do
        Timecop.freeze(Time.zone.local(2015, 10, 3, 12, 0, 0)) do
          shift.enroll_next_shift(user_with_credit)
        end
        Timecop.freeze(Time.zone.local(2015, 11, 5, 12, 0, 0)) do
          expect(user_with_credit.calculate_future_credit(Time.zone.local(2015, 10, 1, 0, 0, 0))).to eq(0)
        end
      end

      it 'returns current credits' do
        Timecop.freeze(Time.zone.local(2015, 10, 4, 12, 15, 0)) do
          shift.enroll_next_shift(user_with_credit)
          old_credits = user_with_credit.reload.credit
          expect(user_with_credit.calculate_future_credit(Time.zone.local(2015, 9, 1, 0, 0, 0))).to eq(old_credits)
        end
      end

      it 'returns future credits' do
        Timecop.freeze(Time.zone.local(2015, 8, 27, 10, 00, 0)) do
          shift.enroll_next_shift(user_with_credit)
        end
        Timecop.freeze(Time.zone.local(2015, 9, 3, 1, 12, 0)) do
          FactoryGirl.create(:payment, user: user_with_credit)
          shift.enroll_next_shift(user_with_credit)
        end
        Timecop.freeze(Time.zone.local(2015, 9, 17, 20, 55, 0)) do
          shift.enroll_next_shift(user_with_credit)
          FactoryGirl.create(:payment, user: user_with_credit)
        end
        Timecop.freeze(Time.zone.local(2015, 10, 2, 12, 15, 0)) do
          FactoryGirl.create(:payment, user: user_with_credit)
          shift.enroll_next_shift(user_with_credit)
        end
        Timecop.freeze(Time.zone.local(2015, 10, 5, 23, 0, 0)) do
          expect(user_with_credit.calculate_future_credit(Time.zone.local(2015, 9, 1, 0, 0, 0))).to eq(10)
        end
      end
    end

  end
end