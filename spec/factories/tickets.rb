FactoryBot.define do
  factory :ticket do
    user
    event
    sequence(:comment) { |i| "comment_#{i}" }
  end
end
