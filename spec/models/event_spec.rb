require 'rails_helper'

RSpec.describe Event, type: :model do
  describe '#create' do
    context '正常に値が保存される場合' do
      it 'is valid with name, place, content, start_time, end_time' do
        event = build(:event)
        expect(event).to be_valid
      end
    end

    context '未入力のカラムが存在する場合' do
      it 'is invalid without name' do
        event = build(:event, name: nil)
        event.valid?
        expect(event.errors[:name]).to include('を入力してください')
      end

      it 'is invalid without place' do
        event = build(:event, place: nil)
        event.valid?
        expect(event.errors[:place]).to include('を入力してください')
      end

      it 'is invalid without content' do
        event = build(:event, content: nil)
        event.valid?
        expect(event.errors[:content]).to include('を入力してください')
      end

      it 'is invalid without start_time' do
        event = build(:event, start_time: nil)
        event.valid?
        expect(event.errors[:start_time]).to include('を入力してください')
      end

      it 'is invalid without end_time' do
        event = build(:event, end_time: nil)
        event.valid?
        expect(event.errors[:end_time]).to include('を入力してください')
      end
    end

    context '文字数が制限値より多いカラムが存在する場合' do
      it 'is invalid with name that has more than 50 characters ' do
        event = build(:event, name: 'a' * 51)
        event.valid?
        expect(event.errors[:name][0]).to include('は50文字以内で入力してください')
      end

      it 'is invalid with place that has more than 100 characters ' do
        event = build(:event, place: 'a' * 101)
        event.valid?
        expect(event.errors[:place][0]).to include('は100文字以内で入力してください')
      end

      it 'is invalid with content that has more than 2000 characters ' do
        event = build(:event, content: 'a' * 2001)
        event.valid?
        expect(event.errors[:content][0]).to include('は2000文字以内で入力してください')
      end
    end

    it 'is invalid with start_time that has larger number than end_time ' do
      event = build(:event, start_time: '2018-05-24 14:10:05', end_time: '2018-05-23 14:10:05')
      event.valid?
      expect(event.errors[:start_time][0]).to include('は終了時間よりも前に設定してください')
    end
  end
end
