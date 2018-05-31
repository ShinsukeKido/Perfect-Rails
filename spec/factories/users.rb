FactoryBot.define do
  factory :user, aliases: [:owner] do
    provider 'sns'
    uid '12345'
    nickname 'tom'
    image_url 'http://image.hoge.com'
  end
end
