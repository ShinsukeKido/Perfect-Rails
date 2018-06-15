require 'rails_helper'

RSpec.describe 'Tickets', type: :system do
  let(:event) { create(:event) }

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

  it 'ログインせずに、イベント参加を試みる' do
    # イベントページへアクセスする
    visit "/events/#{event.id}"

    # 参加を試みても、トップページにリダイレクトする
    click_on '参加する'
    expect(page).to have_content 'ログインしてください'
  end

  it 'ログイン後、正しいコメントを入力し、イベント参加を行う' do
    # ログインする
    visit '/'
    click_on 'Twitterでログイン'

    # イベントページへアクセスする
    visit "/events/#{event.id}"

    # 参加する
    click_on '参加する'
    fill_in 'ticket[comment]', with: 'comment'
    click_on '送信'

    # フラッシュメッセージが表示される
    expect(page).to have_content 'このイベントに参加表明しました'

    # 参加後はイベントページの参加者欄にnickname が追加される参加ボタンが参加済みに変更されている
    expect(page).to have_content '参加者'
    expect(page).to have_content 'hogehoge'

    # 参加ボタンが参加済みに変更されている
    expect(page).to have_content '参加済み'
  end

  it 'ログイン後、31文字以上のコメントを入力し、イベント参加を試みる' do
    # ログインする
    visit '/'
    click_on 'Twitterでログイン'

    # イベントページへアクセスする
    visit "/events/#{event.id}"

    # 参加する
    click_on '参加する'
    fill_in 'ticket[comment]', with: 'a' * 31
    click_on '送信'

    # エラーメッセージが表示される
    expect(page).to have_content 'コメントは30文字以内で入力してください'
  end
end
