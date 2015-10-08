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

    end

  end
end