require 'rails_helper'

RSpec.describe 'Users', type: :system do
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

  context 'ユーザーに退会資格がある場合（公開中終了イベントが存在する）' do
    let!(:event) { create(:event, owner_id: user.id, start_time: Time.zone.now - 2.hours, end_time: Time.zone.now - 1.hour) }

    it 'ユーザーが退会する' do
      # ログインする
      visit '/'
      click_on 'Twitterでログイン'

      # 退会確認ページへアクセスする
      click_on '退会'
      expect(page).to have_content '退会の確認'

      # 退会する
      click_on '退会する'
      expect(page).to have_content '退会完了しました'

      # イベントページの主催者の欄に、'退会したユーザー'と記載される
      visit "/events/#{event.id}"
      expect(page).to have_content '退会したユーザーです'
    end
  end

  context 'ユーザーに退会資格がある場合（終了参加ベントが存在する）' do
    let!(:event) { create(:event, start_time: Time.zone.now - 2.hours, end_time: Time.zone.now - 1.hour) }

    before { create(:ticket, user_id: user.id, event_id: event.id) }
    it 'ユーザーが退会する' do
      # ログインする
      visit '/'
      click_on 'Twitterでログイン'

      # 退会確認ページへアクセスする
      click_on '退会'
      expect(page).to have_content '退会の確認'

      # 退会する
      click_on '退会する'
      expect(page).to have_content '退会完了しました'

      # イベントページの参加者の欄に、'退会したユーザー'と記載される
      visit "/events/#{event.id}"
      expect(page).to have_content '退会したユーザーです'
    end
  end

  context 'ユーザーに公開中未終了イベントが存在する場合' do
    before { create(:event, owner_id: user.id) }
    it 'ユーザーが退会を試みる' do
      # ログインする
      visit '/'
      click_on 'Twitterでログイン'

      # 退会確認ページへアクセスする
      click_on '退会'
      expect(page).to have_content '退会の確認'

      # 退会を試みる
      click_on '退会する'
      expect(page).to have_content '公開中の未終了イベントが存在します'
    end
  end

  context 'ユーザーに未終了参加ベントが存在する場合' do
    before { create(:ticket, user_id: user.id) }
    it 'ユーザーが退会を試みる' do
      # ログインする
      visit '/'
      click_on 'Twitterでログイン'

      # 退会確認ページへアクセスする
      click_on '退会'
      expect(page).to have_content '退会の確認'

      # 退会を試みる
      click_on '退会する'
      expect(page).to have_content '未終了の参加イベントが存在します'
    end
  end
end
