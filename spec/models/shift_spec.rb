require "rails_helper"

describe Shift, :type => :model do
  let(:base_date) { Chronic.parse("2015-10-06 10:00") }
  let(:week_day) { base_date.strftime('%w').to_i + 1 }
  let(:start_time) { base_date.strftime('%H:%M') }
  let(:end_time) { (base_date + 1.hour).strftime('%H:%M') }
  let(:shift_attributes) { { week_day: week_day, start_time: start_time, end_time: end_time } }
  let(:shift) { FactoryGirl.create(:shift, shift_attributes) }
  let(:user_with_credit) { FactoryGirl.create(:user_with_credit) }
  let(:user_without_credit) { FactoryGirl.create(:user) }

  describe '#next_fixed_shift' do
    it 'generates the next shift day' do
      expect(shift.next_fixed_shift.strftime('%Y-%m-%d %H:%M')).to eq(base_date.strftime('%Y-%m-%d %H:%M'))
    end
  end

  describe '#status' do
    it 'returns close' do
      Timecop.freeze(base_date - shift.open_inscription.hour - 1.hour) do
        expect(shift.status).to eq(Shift::STATUS[:close])
      end
    end

    it 'returns open' do
      Timecop.freeze(base_date - shift.open_inscription.hour + 1.hour) do
        expect(shift.status).to eq(Shift::STATUS[:open])
      end
    end

    it 'returns full' do
      shift.update(max_attendants: 0)
      expect(shift.status).to eq(Shift::STATUS[:full])
    end
  end

  describe '#needs_confirmation?' do
    it 'requires confirmation' do
      Timecop.freeze(base_date - shift.cancel_inscription.hour + 1.minute) do
        expect(shift.needs_confirmation?).to eq(true)
      end
    end

    it 'does not require confirmation' do
      Timecop.freeze(base_date - shift.cancel_inscription.hour - 1.minute) do
        expect(shift.needs_confirmation?).to eq(false)
      end
    end
  end

  describe '.get_next_class' do
    it 'returns current shift' do
      current_shift = FactoryGirl.create(:shift,
        week_day: base_date.strftime('%w').to_i + 1,
        start_time: (base_date - 30.minute).strftime('%H:%M'),
        end_time: (base_date + 30.minute).strftime('%H:%M')
      )
      FactoryGirl.create(:shift,
        week_day: base_date.strftime('%w').to_i + 1,
        start_time: (base_date + 1.hour).strftime('%H:%M'),
        end_time: (base_date + 2.hour).strftime('%H:%M')
      )
      Timecop.freeze(base_date) do
        expect(Shift.get_next_class).to eq(current_shift)
      end
    end

    it 'returns next shift on the same day' do
      FactoryGirl.create(:shift,
          week_day: base_date.strftime('%w').to_i,
          start_time: (base_date - 30.minute ).strftime('%H:%M'),
          end_time: (base_date + 30.minute).strftime('%H:%M')
      )

      current_shift = FactoryGirl.create(:shift,
          week_day: base_date.strftime('%w').to_i + 1,
          start_time: (base_date - 30.minute).strftime('%H:%M'),
          end_time: (base_date + 30.minute).strftime('%H:%M')
      )
      FactoryGirl.create(:shift,
          week_day: base_date.strftime('%w').to_i + 2,
          start_time: (base_date - 30.minute ).strftime('%H:%M'),
          end_time: (base_date + 30.minute).strftime('%H:%M')
      )
      Timecop.freeze(base_date - 2.hour) do
        expect(Shift.get_next_class).to eq(current_shift)
      end
    end

    it 'returns next shift on the following day' do
      FactoryGirl.create(:shift,
          week_day: base_date.strftime('%w').to_i,
          start_time: (base_date - 30.minute ).strftime('%H:%M'),
          end_time: (base_date + 30.minute).strftime('%H:%M')
      )

      current_shift = FactoryGirl.create(:shift,
          week_day: base_date.strftime('%w').to_i + 2,
          start_time: (base_date - 30.minute).strftime('%H:%M'),
          end_time: (base_date + 30.minute).strftime('%H:%M')
      )
      Timecop.freeze(base_date) do
        expect(Shift.get_next_class).to eq(current_shift)
      end
    end
  end

  describe '#available_for_enroll?' do
    it 'returns false for user without credit' do
      Timecop.freeze(base_date - shift.open_inscription.hour + 1.hour) do
        expect(shift.available_for_enroll?(user_without_credit)).to eq(false)
      end
    end

    it 'returns false for full shift' do
      shift.update(max_attendants: 0)
      Timecop.freeze(base_date - shift.open_inscription.hour + 1.hour) do
        expect(shift.available_for_enroll?(user_with_credit)).to eq(false)
      end
    end

    it 'returns false for user without the discipline' do
      user_with_credit.disciplines.find_by_name(shift.discipline.name).destroy
      user_with_credit.reload
      Timecop.freeze(base_date - shift.open_inscription.hour + 1.hour) do
        expect(shift.available_for_enroll?(user_with_credit)).to eq(false)
      end
    end

    it 'returns true for user with credit' do
      Timecop.freeze(base_date - shift.open_inscription.hour + 1.hour) do
        expect(shift.available_for_enroll?(user_with_credit)).to eq(true)
      end
    end
  end

  describe '#enroll_next_shift' do
    it 'creates an inscription for the next shift' do
      Timecop.freeze(base_date - shift.open_inscription.hour + 1.hour) do
        shift.enroll_next_shift(user_with_credit)
        expect(shift.inscriptions.where(shift_date: shift.next_fixed_shift).first.user).to eq(user_with_credit)
      end
    end

    it 'returns false for a user without credit' do
      Timecop.freeze(base_date - shift.open_inscription.hour + 1.hour) do
        expect(shift.enroll_next_shift(user_without_credit)).to eq(false)
      end
    end

    it 'returns false for a already enrolled user' do
      Timecop.freeze(base_date - shift.open_inscription.hour + 30.minute) do
        shift.enroll_next_shift(user_with_credit)
      end
      Timecop.freeze(base_date - shift.open_inscription.hour + 1.hour) do
        expect(shift.enroll_next_shift(user_with_credit)).to eq(false)
      end
    end

    it 'returns false for a user with another inscription in the same day' do
      another_shift = FactoryGirl.create(:shift,
          week_day: shift.week_day,
          start_time: (base_date + 1.hour ).strftime('%H:%M'),
          end_time: (base_date + 2.hour).strftime('%H:%M')
      )

      Timecop.freeze(base_date - shift.open_inscription.hour + 30.minute) do
        shift.enroll_next_shift(user_with_credit)
      end

      Timecop.freeze(base_date - shift.open_inscription.hour + 1.hour) do
        expect(another_shift.enroll_next_shift(user_with_credit)).to eq(false)
      end
    end
  end

  describe '#next_fixed_shift_count' do
    it 'returns 0 when there is not any inscription' do
      expect(shift.next_fixed_shift_count).to eq(0)
    end

    it 'returns the number of inscriptions' do
      Timecop.freeze(base_date - shift.open_inscription.hour + 30.minute) do
        users = []
        inscriptions = rand(2..shift.max_attendants)
        inscriptions.times do
          users << FactoryGirl.create(:user_with_credit)
          shift.enroll_next_shift(users.last)
        end
        cancellations = rand(2..inscriptions)
        cancellations.times do |i|
          shift.cancel_next_shift(users[i])
        end
        expect(shift.next_fixed_shift_count).to eq(inscriptions - cancellations)
      end
    end
  end


end
