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
  end

  describe '#new' do
    context 'ログインしている場合' do
      before { get '/auth/twitter/callback' }
      
      it 'new.html.erb ページに遷移する' do
        get '/events/new'
        expect(response).to render_template :new
      end
    end

    context 'ログインしていない場合' do
      it 'トップページにリダイレクトする' do
        get '/events/new'
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#create' do
    context 'ログインしている場合' do
      before { get '/auth/twitter/callback' }

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

    context 'ログインしていない場合' do
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

      it 'params で正しい値が送られても、トップページにリダイレクトする' do
        post '/events', params: params
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#show' do
    let(:event) { create(:event) }

    it 'show.html.erb ページに遷移する' do
      get "/events/#{event.id}"
      expect(response).to render_template :show
    end
  end
end
