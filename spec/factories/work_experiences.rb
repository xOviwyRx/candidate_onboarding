FactoryBot.define do
  factory :work_experience do
    candidate_profile

    job_title { "Dental Hygienist" }
    company_name { "Tandartspraktijk Centrum" }
    responsibilities { "Periodontal treatment, prevention and patient education." }
    start_date { Date.new(2019, 9, 1) }
    end_date { Date.new(2023, 6, 30) }

    trait :current do
      current_job { true }
      end_date { nil }
    end
  end
end
