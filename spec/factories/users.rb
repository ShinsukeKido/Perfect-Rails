FactoryBot.define do
  factory :user do
    provider 'sns'
    uid '12345'
    nickname 'tom'
    image_url 'http://image.hoge.com'
  end
end
