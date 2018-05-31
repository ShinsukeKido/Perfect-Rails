require 'rails_helper'

RSpec.describe 'Welcome', type: :request do
  describe 'root' do
    let!(:events) do
      event1 = create(:event, start_time: Time.zone.now - 2.hours, end_time: Time.zone.now - 1.hour)
      event2 = create(:event, start_time: Time.zone.now + 5.hours, end_time: Time.zone.now + 8.hours)
      event3 = create(:event, start_time: Time.zone.now + 3.hours, end_time: Time.zone.now + 9.hours)
      [event3, event2]
    end

    it 'index.html.erb ページに遷移する' do
      get '/'
      expect(response).to render_template :index
    end

    it '@events に未開催のイベントが開始時間の昇順で格納されている' do
      get '/'
      expect(assigns(:events)).to eq events
    end
  end
end
