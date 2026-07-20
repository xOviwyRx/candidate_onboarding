FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "candidate#{n}@example.com" }
    password { "secret123" }
  end
end
