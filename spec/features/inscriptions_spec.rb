require "rails_helper"

describe 'Inscriptions', :type => :feature, :js => true  do
  let(:user_with_credit) { FactoryGirl.create(:user_with_credit) }
  let(:password) { '12345678' }
  let(:shift_attributes) { { start_time: '10:00', end_time: '11:00' } }
  let!(:shift_monday) { FactoryGirl.create(:shift, shift_attributes.merge!(week_day: 2)) }
  let!(:shift_tuesday) { FactoryGirl.create(:shift, shift_attributes.merge!(week_day: 3)) }
  let!(:shift_wednesday) { FactoryGirl.create(:shift, shift_attributes.merge!(week_day: 4)) }
  let!(:shift_thursday) { FactoryGirl.create(:shift, shift_attributes.merge!(week_day: 5)) }
  let!(:shift_friday) { FactoryGirl.create(:shift, shift_attributes.merge!(week_day: 6)) }
  let!(:shift_saturday) { FactoryGirl.create(:shift, shift_attributes.merge!(week_day: 7)) }

  def login_as_user
    visit '/users/sign_in'
    fill_in 'user_email', :with => user_with_credit.email
    fill_in 'user_password', :with => password
    click_on 'sign_in'
    expect(current_path).to eq(inscriptions_path)
  end

  def load_classes
    expect(page).to have_selector('#loading')
    expect(page).to have_no_selector('#loading')
  end

  it 'shows all classes' do
    # 7:00 Monday, October 12th
    Timecop.freeze(Time.zone.local(2015, 10, 12, 7, 0, 0)) do
      login_as_user
      expect(page).to have_css('#loading')
      Shift.find_each do |shift|
        expect(find("#shift-#{shift.id}")).to have_content(shift.discipline.name)
      end
    end
  end

  it 'enrolls into an opened class' do
    # 7:00 Monday, October 12th
    Timecop.freeze(Time.zone.local(2015, 10, 12 , 7, 0, 0)) do
      login_as_user

      # Loading classes
      load_classes
      credits_before = find('#user-credit').text.to_i

      find("#shift-#{shift_monday.id}").click

      # Modals
      expect(page).to have_selector('#loading')
      expect(find('#bookModal')).to have_content(shift_monday.discipline.name)
      find('#bookModal').find('#accept-book').click
      expect(page).to have_no_selector('#loading')

      expect(find('#user-credit').text.to_i).to eq(credits_before - 1)
      expect(page).to have_selector("#shift-#{shift_monday.id} span.glyphicon-ok-sign")
    end
  end

  it 'does not enroll into a closed class' do
    Timecop.freeze(shift_monday.next_fixed_shift - shift_monday.open_inscription.hour - 1.minute) do
      login_as_user

      # Loading classes
      load_classes
      credits_before = find('#user-credit').text.to_i

      expect(find("#shift-#{shift_monday.id}")['style']).to include('cursor: not-allowed')
      find("#shift-#{shift_monday.id}").click

      expect(find('#user-credit').text.to_i).to eq(credits_before)
      expect(page).to have_no_selector("#shift-#{shift_monday.id} span.glyphicon-ok-sign")
    end
  end

  it 'enrolls to a last hour class after confirmation' do
    Timecop.freeze(shift_monday.next_fixed_shift - shift_monday.cancel_inscription.hour + 1.minute) do
      login_as_user

      # Loading classes
      load_classes
      credits_before = find('#user-credit').text.to_i

      find("#shift-#{shift_monday.id}").click

      # Confirmation modal
      expect(page).to have_selector('div.bootbox-confirm')
      click_on 'Aceptar'

      # Modals
      expect(page).to have_selector('#loading')
      expect(find('#bookModal')).to have_content(shift_monday.discipline.name)
      find('#bookModal').find('#accept-book').click
      expect(page).to have_no_selector('#loading')

      expect(find('#user-credit').text.to_i).to eq(credits_before - 1)
      expect(page).to have_selector("#shift-#{shift_monday.id} span.glyphicon-ok-sign")
    end
  end

  it 'does not enroll to a last hour class if is not confirmed' do
    Timecop.freeze(shift_monday.next_fixed_shift - shift_monday.cancel_inscription.hour + 1.minute) do
      login_as_user

      # Loading classes
      load_classes
      credits_before = find('#user-credit').text.to_i

      find("#shift-#{shift_monday.id}").click

      # Confirmation modal
      expect(page).to have_selector('div.bootbox-confirm')
      click_on 'Cancelar'

      # Modals
      expect(page).to have_no_selector('#loading')

      expect(find('#user-credit').text.to_i).to eq(credits_before)
      expect(page).to have_no_selector("#shift-#{shift_monday.id} span.glyphicon-ok-sign")
    end
  end

end