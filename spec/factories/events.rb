FactoryBot.define do
  factory :event do
    owner_id 1
    name 'meetup'
    place 'shinjuku'
    start_time DateTime.new(2018, 5, 28, 14, 00)
    end_time DateTime.new(2018, 5, 28, 15, 00)
    content 'MyText'
  end
end
