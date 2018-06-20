require 'rails_helper'

RSpec.describe 'UsersController', type: :request do
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

  describe '#retire' do
    context 'ログインしている場合' do
      before { get '/auth/twitter/callback' }

      it 'retire.html.erb ページに遷移する' do
        get '/user/retire'
        expect(response).to render_template :retire
      end
    end

    context 'ログインしていない場合' do
      it 'トップページにリダイレクトする' do
        get '/user/retire'
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#destroy' do
    context 'ログインしている場合' do
      before { get '/auth/twitter/callback' }

      context 'ユーザーに退会の権利がある場合' do
        it 'ユーザーを削除する' do
          expect { delete '/user' }.to change { User.count }.by(-1)
        end

        it 'ログアウトされる' do
          delete '/user'
          expect(session[:user_id]).to be_nil
        end

        it 'トップページへリダイレクトする' do
          delete '/user'
          expect(response).to redirect_to root_path
        end

        it 'フラッシュメッセージが表示される' do
          delete '/user'
          expect(flash[:notice]).to eq '退会完了しました'
        end
      end

      context 'ユーザーに退会の権利が無い場合（公開中未終了イベントが存在する）' do
        before { create(:event, owner_id: user.id) }

        it 'ユーザーを削除できない' do
          expect { delete '/user' }.not_to change { User.count }
        end

        it 'retire.html.erb ページに遷移する' do
          delete '/user'
          expect(response).to render_template :retire
        end
      end
    end

    context 'ログインしていない場合' do
      it 'ユーザーを削除できない' do
        expect { delete '/user' }.not_to change { User.count }
      end

      it 'トップページへリダイレクトする' do
        delete '/user'
        expect(response).to redirect_to root_path
      end
    end
  end
end
