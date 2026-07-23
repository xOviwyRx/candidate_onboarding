FactoryBot.define do
  factory :skill do
    sequence(:name) { |n| "Skill #{n}" }
    job_functions { [ "dental_assistant" ] }
  end
end
