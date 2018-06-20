require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#self.find_or_create_from_auth_hash(auth_hash)' do
    subject { User.find_or_create_from_auth_hash(OmniAuth.config.mock_auth[:twitter]) }

    before do
      OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(
        provider: 'twitter',
        uid: '0123456789',
        info: {
          nickname: 'hogehoge',
          image: 'http://image.example.com',
        },
      )
    end

    context 'users テーブルにレコードがない場合' do
      it 'ユーザーを新規作成する' do
        expect { subject }.to change { User.count }.by(1)
      end
    end

    context 'userの各カラムの値が、OmniAuthの各値と一致する場合' do
      let!(:user) do
        create(
          :user,
          provider: 'twitter',
          uid: '0123456789',
          nickname: 'hogehoge',
          image_url: 'http://image.example.com',
        )
      end

      it 'ユーザーを作成しない' do
        expect { subject }.not_to change { User.count }
      end
    end

    context 'userのprovider、uidの値が、OmniAuthの値と一致しない場合' do
      let!(:user) do
        create(
          :user,
          provider: 'facebook',
          uid: '9876543210',
          nickname: 'hogehoge',
          image_url: 'http://image.example.com',
        )
      end

      it 'ユーザーを新規作成する' do
        expect { subject }.to change { User.count }.by(1)
      end
    end
  end

  describe '#check_all_events_finished' do
    subject { user.destroy }

    context 'userの公開中未終了イベント、未終了参加イベントが共に存在しない場合' do
      let!(:user) { create(:user) }

      it 'ユーザーを削除する' do
        expect { subject }.to change { User.count }.by(-1)
      end
    end

    context 'userの公開中未終了イベントが存在する場合' do
      let!(:user) { create(:user) }
      let!(:event) { create(:event, owner_id: user.id, start_time: Time.zone.now + 1.hour, end_time: Time.zone.now + 2.hours) }

      it 'ユーザーを削除しない' do
        expect { subject }.not_to change { User.count }
      end

      it 'エラーメッセージが追加される' do
        subject
        expect(user.errors[:base]).to include('公開中の未終了イベントが存在します。')
      end

      it 'false を返す' do
        is_expected.to eq false
      end
    end

    context 'userの未終了参加イベントが存在する場合' do
      let!(:user) { create(:user) }
      let!(:event) { create(:event, start_time: Time.zone.now + 1.hour, end_time: Time.zone.now + 2.hours) }
      let!(:ticket) { create(:ticket, user_id: user.id, event_id: event.id) }

      it 'ユーザーを削除しない' do
        expect { subject }.not_to change { User.count }
      end

      it 'エラーメッセージが追加される' do
        subject
        expect(user.errors[:base]).to include('未終了の参加イベントが存在します。')
      end

      it 'false を返す' do
        is_expected.to eq false
      end
    end
  end
end
