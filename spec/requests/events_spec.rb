require 'rails_helper'

RSpec.describe 'EventsController', type: :request do
  context 'ログインが必要な場合' do
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
      it 'new.html.erb ページに遷移する' do
        get '/events/new'
        expect(response).to render_template :new
      end
    end

    describe '#create' do
      context 'イベント作成ページで、正しい値が入力された場合' do
        let(:params) do
          {
            event: {
              name: 'event',
              place: 'place',
              content: 'sentence',
              start_time: Time.zone.local(2018, 5, 28, 14, 0o0),
              end_time: Time.zone.local(2018, 5, 28, 15, 0o0),
            },
          }
        end

        it 'イベントを新規作成する' do
          expect { post '/events', params: params }.to change { Event.count }.by(1)
        end

        it 'show.html.erb ページへリダイレクトする' do
          post '/events', params: params
          expect(response).to redirect_to Event.last
        end
      end

      context 'イベント作成ページで、正しくない値が入力された場合' do
        let(:params) do
          {
            event: {
              name: 'event',
              place: 'tokyo',
              content: 'sentence',
              start_time: Time.zone.local(2018, 5, 28, 14, 0o0),
              end_time: Time.zone.local(2018, 5, 28, 14, 0o0),
            },
          }
        end

        it '新しいイベントが作成されない' do
          expect { post '/events', params: params }.not_to change { Event.count }
        end

        it 'new.html.erb ページに遷移する' do
          post '/events', params: params
          expect(response).to render_template :new
        end
      end
    end
  end

  context 'ログインが不要な場合' do
    describe '#show' do
      let(:event) { create(:event) }

      it 'show.html.erb ページに遷移する' do
        get "/events/#{event.id}"
        expect(response).to render_template :show
      end
    end
  end
end
