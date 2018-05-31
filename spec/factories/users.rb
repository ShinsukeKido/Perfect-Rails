FactoryBot.define do
  factory :user, aliases: [:owner] do
    provider 'sns'
    sequence(:uid) { |i| "uid#{i}" }
    nickname 'tom'
    image_url 'http://image.hoge.com'
  end
end
