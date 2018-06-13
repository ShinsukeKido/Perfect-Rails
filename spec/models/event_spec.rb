require 'rails_helper'

RSpec.describe Event, type: :model do
  describe '#name' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(50) }
  end

  describe '#place' do
    it { should validate_presence_of(:place) }
    it { should validate_length_of(:place).is_at_most(100) }
  end

  describe '#content' do
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:content).is_at_most(2000) }
  end

  describe '#start_time' do
    before { travel_to Time.zone.local(2018, 1, 1, 0o0, 0o0) }

    it { should validate_presence_of(:start_time) }

    it 'start_timeがend_timeより遅いとバリデーションエラーが起きる ' do
      event = build(:event, owner_id: 1, start_time: Time.zone.local(2018, 5, 28, 15, 0o0), end_time: Time.zone.local(2018, 5, 28, 14, 0o0))
      expect(event).to be_invalid
    end
  end

  describe '#end_time' do
    it { should validate_presence_of(:end_time) }
  end

  describe '#created_by?(user)' do
    subject { event.created_by?(user) }

    context 'userがeventを作成している場合' do
      let(:user) { create(:user) }
      let(:event) { create(:event, owner_id: user.id) }

      it 'true を返す' do
        is_expected.to eq true
      end
    end

    context 'userがeventを作成していない場合' do
      let(:user) { create(:user) }
      let(:event) { create(:event) }

      it 'false を返す' do
        is_expected.to eq false
      end
    end

    context 'userが存在ない場合' do
      let(:user) { nil }
      let(:event) { create(:event) }

      it 'false を返す' do
        is_expected.to eq false
      end
    end
  end
end
