require 'rails_helper'

RSpec.describe 'TicketsController', type: :request do
  let(:event) { create(:event) }

  let!(:user) do
    create(
      :user,
      provider: 'twitter',
      uid: '0123456789',
      nickname: 'hogehoge',
      image_url: 'http://image.example.com',
    )
  end

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

      it 'error.html.erb ページに遷移する' do
        get "/events/#{event.id}/tickets/new"
        expect(response).to render_template :error404
      end
    end

    context 'ログインしていない場合' do
      it 'トップページにリダイレクトする' do
        get "/events/#{event.id}/tickets/new"
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#create' do
    context 'ログインしている場合' do
      before { get '/auth/twitter/callback' }

      context '該当イベントにまだ参加していない場合' do
        context 'チケット作成 のmodalで、正しい値が入力された場合' do
          let(:params) do
            {
              ticket: {
                comment: 'comment',
              },
            }
          end

          it 'チケットを新規作成する' do
            expect { post "/events/#{event.id}/tickets", params: params }.to change { Ticket.count }.by(1)
          end

          it 'ステータスコード201 が返る' do
            post "/events/#{event.id}/tickets", params: params
            expect(response.status).to eq 201
          end

          it 'フラッシュメッセージが表示される' do
            post "/events/#{event.id}/tickets", params: params
            expect(flash[:notice]).to eq 'このイベントに参加表明しました'
          end
        end

        context 'チケット作成のmodal で、comment が31文字以上だった場合' do
          let(:params) do
            {
              ticket: {
                comment: 'a' * 31,
              },
            }
          end

          it '新しいチケットが作成されない' do
            expect { post "/events/#{event.id}/tickets", params: params }.not_to change { Ticket.count }
          end

          it 'ステータスコード422 が返る' do
            post "/events/#{event.id}/tickets", params: params
            expect(response.status).to eq 422
          end
        end
      end

      context '該当イベントに参加している場合' do
        let(:params) do
          {
            ticket: {
              comment: 'comment',
            },
          }
        end

        before { post "/events/#{event.id}/tickets", params: params }

        it 'paramsで正しい値を送っても、ActiveRecord::RecordNotUniqueが発生する' do
          expect { post "/events/#{event.id}/tickets", params: params }.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end
    end

    context 'ログインしていない場合' do
      let(:params) do
        {
          ticket: {
            comment: 'comment',
          },
        }
      end

      it 'params で正しい値が送られても、新しいイベントが作成されない' do
        expect { post "/events/#{event.id}/tickets", params: params }.not_to change { Ticket.count }
      end

      it 'トップページにリダイレクトする' do
        post "/events/#{event.id}/tickets", params: params
        expect(response).to redirect_to root_path
      end
    end
  end
end
