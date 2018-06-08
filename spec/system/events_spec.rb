require 'rails_helper'

RSpec.describe 'Events', type: :system do
  before do
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(
      provider: 'twitter',
      uid: '0123456789',
      info: {
        nickname: 'hogehoge',
        image: 'http://image.example.com',
      },
    )

    # 現在時刻を、2018/01/01 00:00 に設定
    travel_to Time.zone.local(2018, 1, 1, 0o0, 0o0)

    # ログインユーザー以外のユーザーが作成したイベントを用意しておく
    create(:event, name: 'other_user_event')
  end

  it 'トップページからログイン、イベント作成、イベント閲覧、ログアウト後のイベント閲覧を順番に行う' do
    # トップページへアクセスする
    visit '/'

    # ログインする
    click_on 'Twitterでログイン'

    # 開始時間が未来のイベントを作成する
    click_on 'イベントを作る'
    fill_in 'event[name]', with: 'future_event'
    fill_in 'event[place]', with: 'place_1'
    select '2018', from: 'event[start_time(1i)]'
    select '7', from: 'event[start_time(2i)]'
    select '1', from: 'event[start_time(3i)]'
    select '12', from: 'event[start_time(4i)]'
    select '00', from: 'event[start_time(5i)]'
    select '2018', from: 'event[end_time(1i)]'
    select '7', from: 'event[end_time(2i)]'
    select '1', from: 'event[end_time(3i)]'
    select '13', from: 'event[end_time(4i)]'
    select '00', from: 'event[end_time(5i)]'
    fill_in 'event[content]', with: 'content_1'
    click_on '作成'

    # 作成したイベントの詳細ページへ遷移していることの確認
    expect(page).to have_content '作成しました'
    expect(page).to have_content 'future_event'
    expect(page).to have_content 'place_1'
    expect(page).to have_content '2018/07/01 12:00'
    expect(page).to have_content '2018/07/01 13:00'
    expect(page).to have_content 'content_1'
    expect(page).to have_content 'hogehoge'

    # 開始時間が過去のイベントを作成する
    click_on 'イベントを作る'
    fill_in 'event[name]', with: 'past_event'
    fill_in 'event[place]', with: 'place_2'
    select '2017', from: 'event[start_time(1i)]'
    select '7', from: 'event[start_time(2i)]'
    select '1', from: 'event[start_time(3i)]'
    select '12', from: 'event[start_time(4i)]'
    select '00', from: 'event[start_time(5i)]'
    select '2017', from: 'event[end_time(1i)]'
    select '7', from: 'event[end_time(2i)]'
    select '1', from: 'event[end_time(3i)]'
    select '13', from: 'event[end_time(4i)]'
    select '00', from: 'event[end_time(5i)]'
    fill_in 'event[content]', with: 'content_2'
    click_on '作成'

    # 作成したイベントの詳細ページへ遷移していることの確認
    expect(page).to have_content '作成しました'
    expect(page).to have_content 'past_event'
    expect(page).to have_content 'place_2'
    expect(page).to have_content '2017/07/01 12:00'
    expect(page).to have_content '2017/07/01 13:00'
    expect(page).to have_content 'content_2'
    expect(page).to have_content 'hogehoge'

    # トップページへアクセスし、開始時間が未来のイベントのみ表示されていることの確認
    click_on 'AwesomeEvents'
    expect(page).to have_content 'future_event'
    expect(page).to have_content '2018/07/01 12:00'
    expect(page).to have_content '2018/07/01 13:00'
    expect(page).not_to have_content 'past_event'

    # イベント詳細ページにアクセスできることの確認
    click_on 'future_event'
    expect(page).to have_content 'future_event'
    expect(page).to have_content 'place_1'
    expect(page).to have_content '2018/07/01 12:00'
    expect(page).to have_content '2018/07/01 13:00'
    expect(page).to have_content 'content_1'
    expect(page).to have_content 'hogehoge'

    # イベント編集ページにアクセスできることの確認
    click_on 'イベントを編集する'

    # 無効な値は弾かれる弾かれることの確認
    select '2014', from: 'event[end_time(1i)]'
    click_on '更新'
    expect(page).to have_content '開始時間は終了時間よりも前に設定してください'

    # イベントを更新できることの確認
    select '2019', from: 'event[end_time(1i)]'
    click_on '更新'
    expect(page).to have_content '更新しました'

    # ログアウト後も、トップページに開始時間が未来のイベントが表示されていることの確認
    click_on 'ログアウト'
    expect(page).to have_content 'future_event'
    expect(page).to have_content '2018/07/01 12:00'
    expect(page).to have_content '2019/07/01 13:00'
    expect(page).not_to have_content 'past_event'

    # ログアウト後はイベント作成ページにアクセスできないことの確認
    click_on 'イベントを作る'
    expect(page).to have_content 'ログインしてください'
    expect(page).to have_content 'イベント一覧'

    # ログアウト後も、イベント詳細ページにアクセスできることの確認
    click_on 'future_event'
    expect(page).to have_content 'future_event'
    expect(page).to have_content 'place_1'
    expect(page).to have_content '2018/07/01 12:00'
    expect(page).to have_content '2019/07/01 13:00'
    expect(page).to have_content 'content_1'
    expect(page).to have_content 'hogehoge'

    # ログアウト後は、イベント編集、イベント削除のリンクが無いことの確認
    expect(page).not_to have_content 'イベントを編集する'
    expect(page).not_to have_content 'イベントを削除する'

    # イベントを削除できることの確認
    click_on 'Twitterでログイン'
    click_on 'future_event'
    click_on 'イベントを削除する'
    expect(page.driver.browser.switch_to.alert.text).to eq '本当に削除しますか？'
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content '削除しました'
    expect(page).not_to have_content 'future_event'

    # 他のユーザーが作成したイベントの詳細ページには、イベント編集、イベント削除のリンクが無いことの確認
    click_on 'other_user_event'
    expect(page).not_to have_content 'イベントを編集する'
    expect(page).not_to have_content 'イベントを削除する'
  end
end
