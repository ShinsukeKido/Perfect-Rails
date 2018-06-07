FactoryBot.define do
  factory :user, aliases: [:owner] do
    provider 'sns'
    sequence(:uid) { |i| "uid_#{i}" }
    sequence(:nickname) { |i| "nickname_#{i}" }
    sequence(:image_url) { |i| "http://exam.com/image_#{i}.jpg" }
  end
end
