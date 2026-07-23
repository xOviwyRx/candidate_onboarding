FactoryBot.define do
  factory :candidate_profile do
    user

    first_name { "Anna" }
    last_name { "de Vries" }
    sequence(:email) { |n| "anna#{n}@example.com" }
    phone_number { "+31 6 12345678" }
    city { "Amsterdam" }
    country { "Netherlands" }
    job_function { "dental_assistant" }
    preferred_regions { [ "noord_holland" ] }
    max_travel_time { 45 }
    transport_types { [ "car" ] }
    search_status { "active" }
    employment_types { [ "employed" ] }
    desired_gross_salary { 3500 }
    years_of_experience { 5.0 }
    available_working_days { %w[monday tuesday wednesday] }
    available_from { Date.current }
    consent { "1" }

    # §3.1 requires at least one language. Built rather than created so the
    # profile still saves in one go, and skipped when a spec supplies its own.
    after(:build) do |profile|
      next if profile.candidate_languages.any?

      profile.candidate_languages.build(language: Language.find_or_create_by!(name: "Dutch"), level: "native")
    end

    trait :self_employed do
      employment_types { [ "self_employed" ] }
      desired_gross_salary { nil }
      desired_percentage { 40 }
    end

    trait :big_registered do
      job_function { "dental_hygienist" }
      big_registration_status { "registered" }
      big_number { "12345678" }
    end
  end
end
