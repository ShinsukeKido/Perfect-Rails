FactoryBot.define do
  factory :event do
    owner
    sequence(:name) { |i| "イベント名_#{i}" }
    sequence(:place) { |i| "イベント開催場所_#{i}" }
    sequence(:content) { |i| "イベント本文_#{i}" }
    start_time { Time.zone.now + rand(1..30).hours }
    end_time { start_time + rand(1..30).hours }
  end
end
