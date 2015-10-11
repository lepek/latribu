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

    describe '#full_name' do
      it 'returns the full name' do
        expect(user.full_name).to eq('John Doe')
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