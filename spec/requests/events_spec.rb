require 'rails_helper'

RSpec.describe 'EventsController', type: :request do
  before do
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(
      provider: 'twitter',
      uid: '0123456789',
      info: {
        nickname: 'hogehoge',
        image: 'http://image.example.com',
      },
    )
    get '/auth/twitter/callback'
  end

  describe '#new' do
    subject { get '/events/new' }
    it '@event が新しく作成される' do
      subject
      expect(assigns(:event)).to be_a_new(Event)
    end

    it 'new.html.erb ページに遷移する' do
      subject
      expect(response).to render_template :new
    end
  end

  describe '#create' do
    subject do
      post '/events',
           params: params
    end

    context 'イベント作成ページで、正しい値が入力された場合' do
      let(:params) do
        {
          event: {
            owner_id: 1,
            name: 'event',
            place: 'place',
            content: 'sentence',
            start_time: DateTime.new(2018, 5, 28, 14, 00),
            end_time: DateTime.new(2018, 5, 28, 15, 00),
          },
        }
      end

      it 'イベントを新規作成する' do
        expect { subject }.to change { Event.count }.by(1)
      end
    end
    context 'イベント作成ページで、正しくない値が入力された場合' do
      let(:params) do
        {
          event: {
            owner_id: 1,
            name: 'event',
            place: 'tokyo',
            content: 'sentence',
            start_time: DateTime.new(2018, 5, 28, 14, 00),
            end_time: DateTime.new(2018, 5, 28, 14, 00),
          },
        }
      end

      it '新しいイベントが作成されない' do
        expect { subject }.not_to change { Event.count }
      end

      it 'new.html.erb ページに遷移する' do
        subject
        expect(response).to render_template :new
      end
    end
  end
end
