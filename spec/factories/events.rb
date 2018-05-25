FactoryBot.define do
  factory :event do
    owner_id 1
    name 'meetup'
    place 'shinjuku'
    start_time '2018-05-25 16:06:22'
    end_time '2018-05-25 17:06:22'
    content 'MyText'
  end
end
