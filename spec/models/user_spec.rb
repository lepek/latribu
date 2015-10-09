require "rails_helper"

describe User, :type => :model do
  context "when user is an admin" do
    let(:admin) { FactoryGirl.create(:admin) }

    describe '#admin?' do
      it 'returns true for admin user' do
        expect(admin.admin?).to be(true)
      end
    end

  end

  context "when user is a client" do

    let(:user) { FactoryGirl.create(:user) }
    let(:shift) { FactoryGirl.create(:shift) }

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

    describe '.reset_credits' do
      it 'resets all the credits' do
        user_with_credit = nil
        Timecop.freeze(Time.zone.local(2015, 10, 3, 12, 0, 0)) do
          user_with_credit = FactoryGirl.create(:user_with_credit)
          shift.enroll_next_shift(user_with_credit)
        end
        Timecop.freeze(Time.zone.local(2015, 11, 5, 12, 0, 0)) do
          User.reset_credits(Time.zone.local(2015, 10, 1, 0, 0, 0))
        end
        expect(user_with_credit.reload.credit).to eq(0)
      end

      it 'does not reset credits of next month' do
        Timecop.freeze(Time.zone.local(2015, 10, 4, 12, 15, 0)) do
          user_with_credit = FactoryGirl.create(:user_with_credit)
          shift.enroll_next_shift(user_with_credit)
          old_credits = user_with_credit.reload.credit
          User.reset_credits(Time.zone.local(2015, 9, 1, 0, 0, 0))
          expect(user_with_credit.reload.credit).to eq(old_credits)
        end
      end

      it 'only reset some credits' do
        user_with_credit = nil
        Timecop.freeze(Time.zone.local(2015, 8, 27, 10, 00, 0)) do
          user_with_credit = FactoryGirl.create(:user_with_credit)
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
          User.reset_credits(Time.zone.local(2015, 9, 1, 0, 0, 0))
          expect(user_with_credit.reload.credit).to eq(10)
        end
      end

      it 'only reset credits from previous payment' do
        user_with_credit = nil
        Timecop.freeze(Time.zone.local(2015, 9, 17, 20, 55, 0)) do
          user_with_credit = FactoryGirl.create(:user_with_credit)
        end
        Timecop.freeze(Time.zone.local(2015, 10, 2, 12, 15, 0)) do
          FactoryGirl.create(:payment, user: user_with_credit)
          shift.enroll_next_shift(user_with_credit)
        end
        Timecop.freeze(Time.zone.local(2015, 10, 5, 23, 0, 0)) do
          User.reset_credits(Time.zone.local(2015, 9, 1, 0, 0, 0))
          expect(user_with_credit.reload.credit).to eq(10)
        end
      end

    end

  end
end