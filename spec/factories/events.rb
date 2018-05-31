FactoryBot.define do
  factory :event do
    owner
    name 'meetup'
    place 'shinjuku'
    start_time Time.zone.local(2018, 5, 28, 14, 0o0)
    end_time Time.zone.local(2018, 5, 28, 15, 0o0)
    content 'MyText'
  end
end
