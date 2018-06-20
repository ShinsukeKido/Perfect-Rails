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

  describe '#create' do
    context 'ログインしている場合' do
      before { get '/auth/twitter/callback' }

      context '該当イベントにまだ参加していない場合' do
        context 'チケット作成 のmodalで、正しい値が入力された場合' do
          let(:params) { { ticket: { comment: 'comment' } } }

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
          let(:params) { { ticket: { comment: 'a' * 31 } } }

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
        let(:params) { { ticket: { comment: 'comment' } } }

        before { post "/events/#{event.id}/tickets", params: params }

        it 'paramsで正しい値を送っても、ActiveRecord::RecordNotUniqueが発生する' do
          expect { post "/events/#{event.id}/tickets", params: params }.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end
    end

    context 'ログインしていない場合' do
      let(:params) { { ticket: { comment: 'comment' } } }

      it 'params で正しい値が送られても、新しいイベントが作成されない' do
        expect { post "/events/#{event.id}/tickets", params: params }.not_to change { Ticket.count }
      end

      it 'トップページにリダイレクトする' do
        post "/events/#{event.id}/tickets", params: params
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#destroy' do
    context 'ログインしている場合' do
      before { get '/auth/twitter/callback' }

      context '対象のチケットを、ログインユーザーが作成している場合' do
        let!(:ticket) { create(:ticket, user_id: user.id, event_id: event.id) }

        it 'イベントを削除する' do
          expect { delete "/events/#{event.id}/tickets/#{ticket.id}" }.to change { Ticket.count }.by(-1)
        end

        it 'イベントページへリダイレクトする' do
          delete "/events/#{event.id}/tickets/#{ticket.id}"
          expect(response).to redirect_to event
        end

        it 'フラッシュメッセージが表示される' do
          delete "/events/#{event.id}/tickets/#{ticket.id}"
          expect(flash[:notice]).to eq 'このイベントの参加をキャンセルしました'
        end
      end

      context '対象のチケットを、ログインユーザー以外のユーザーが作成している場合' do
        let!(:ticket) { create(:ticket, event_id: event.id) }

        it 'チケットを削除できない' do
          expect { delete "/events/#{event.id}/tickets/#{ticket.id}" }.not_to change { Ticket.count }
        end

        it '404 ページに遷移する' do
          delete "/events/#{event.id}/tickets/#{ticket.id}"
          expect(response).to render_template :error404
        end
      end
    end

    context 'ログインしていない場合' do
      let!(:ticket) { create(:ticket, event_id: event.id) }

      it 'チケットを削除できない' do
        expect { delete "/events/#{event.id}/tickets/#{ticket.id}" }.not_to change { Ticket.count }
      end

      it 'トップページへリダイレクトする' do
        delete "/events/#{event.id}/tickets/#{ticket.id}"
        expect(response).to redirect_to root_path
      end
    end
  end
end
