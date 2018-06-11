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
        before { travel_to Time.zone.local(2018, 1, 1, 0o0, 0o0) }

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
        before { travel_to Time.zone.local(2018, 1, 1, 0o0, 0o0) }

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
      before { travel_to Time.zone.local(2018, 1, 1, 0o0, 0o0) }

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

      it 'params で正しい値が送られても、新しいイベントが作成されない' do
        expect { post '/events', params: params }.not_to change { Event.count }
      end

      it 'トップページにリダイレクトする' do
        post '/events', params: params
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#show' do
    let(:event) { create(:event) }

    context 'ログインしている場合' do
      before { get '/auth/twitter/callback' }

      it 'show.html.erb ページに遷移する' do
        get "/events/#{event.id}"
        expect(response).to render_template :show
      end
    end

    context 'ログインしていない場合' do
      it 'show.html.erb ページに遷移する' do
        get "/events/#{event.id}"
        expect(response).to render_template :show
      end
    end
  end

  describe '#edit' do
    context 'ログインしている場合' do
      before { get '/auth/twitter/callback' }

      context '対象のイベントを、ログインユーザーが作成している場合' do
        let(:event) { create(:event, owner_id: User.first.id) }

        it 'edit.html.erb ページに遷移する' do
          get "/events/#{event.id}/edit"
          expect(response).to render_template :edit
        end
      end

      context '対象のイベントを、ログインユーザー以外のユーザーが作成している場合' do
        let(:event) { create(:event) }

        it 'error.html.erb ページに遷移する' do
          get "/events/#{event.id}/edit"
          expect(response).to render_template :error404
        end
      end
    end

    context 'ログインしていない場合' do
      let(:event) { create(:event) }

      it 'トップページにリダイレクトする' do
        get "/events/#{event.id}/edit"
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#update' do
    context 'ログインしている場合' do
      before { get '/auth/twitter/callback' }

      context '対象のイベントを、ログインユーザーが作成している場合' do
        let(:event) { create(:event, owner_id: User.first.id) }

        context 'イベント編集ページで、正しい値が入力された場合' do
          before { travel_to Time.zone.local(2018, 1, 1, 0o0, 0o0) }

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

          it 'イベントを更新する' do
            patch "/events/#{event.id}/", params: params
            expect(event.name).not_to eq Event.last.name
          end

          it 'show.html.erb ページにリダイレクトする' do
            patch "/events/#{event.id}/", params: params
            expect(response).to redirect_to Event.last
          end
        end

        context 'イベント編集ページで、正しくない値が入力された場合' do
          before { travel_to Time.zone.local(2018, 1, 1, 0o0, 0o0) }

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

          it 'イベントを更新しない' do
            patch "/events/#{event.id}/", params: params
            expect(event.name).to eq Event.last.name
          end

          it 'edit.html.erb ページに遷移する' do
            patch "/events/#{event.id}/", params: params
            expect(response).to render_template :edit
          end
        end
      end

      context '対象のイベントを、ログインユーザー以外のユーザーが作成している場合' do
        let(:event) { create(:event) }
        before { travel_to Time.zone.local(2018, 1, 1, 0o0, 0o0) }


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

        it 'params で正しい値が送られても、イベントが更新されない' do
          patch "/events/#{event.id}/", params: params
          expect(event.name).to eq Event.last.name
        end

        it 'error.html.erb ページに遷移する' do
          get "/events/#{event.id}/edit"
          expect(response).to render_template :error404
        end
      end
    end

    context 'ログインしていない場合' do
      let(:event) { create(:event) }
      before { travel_to Time.zone.local(2018, 1, 1, 0o0, 0o0) }


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

      it 'params で正しい値が送られても、イベントが更新されない' do
        patch "/events/#{event.id}/", params: params
        expect(event.name).to eq Event.last.name
      end

      it 'トップページにリダイレクトする' do
        patch "/events/#{event.id}/", params: params
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#destroy' do
    context 'ログインしている場合' do
      before { get '/auth/twitter/callback' }

      context '対象のイベントを、ログインユーザーが作成している場合' do
        let!(:event) { create(:event, owner_id: User.first.id) }

        it 'イベントを削除する' do
          expect { delete "/events/#{event.id}" }.to change { Event.count }.by(-1)
        end

        it 'トップページへリダイレクトする' do
          delete "/events/#{event.id}"
          expect(response).to redirect_to root_path
        end
      end

      context '対象のイベントを、ログインユーザー以外のユーザーが作成している場合' do
        let!(:event) { create(:event) }

        it 'イベントを削除できない' do
          expect { delete "/events/#{event.id}" }.not_to change { Event.count }
        end

        it 'error.html.erb ページに遷移する' do
          get "/events/#{event.id}/edit"
          expect(response).to render_template :error404
        end
      end
    end

    context 'ログインしていない場合' do
      let!(:event) { create(:event) }

      it 'イベントを削除できない' do
        expect { delete "/events/#{event.id}" }.not_to change { Event.count }
      end

      it 'トップページへリダイレクトする' do
        delete "/events/#{event.id}"
        expect(response).to redirect_to root_path
      end
    end
  end
end
