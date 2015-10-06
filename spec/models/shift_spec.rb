require "rails_helper"

describe Shift, :type => :model do
  let(:base_date) { Chronic.parse("now") }
  let(:week_day) { base_date.strftime('%w').to_i + 1 }
  let(:start_time) { base_date.strftime('%H:%M') }
  let(:end_time) { (base_date + 1.hour).strftime('%H:%M') }
  let(:shift_attributes) { { week_day: week_day, start_time: start_time, end_time: end_time, open_inscription: 12, cancel_inscription: 2 } }
  let(:shift) { FactoryGirl.create(:shift, shift_attributes) }

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

end
