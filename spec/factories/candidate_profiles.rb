FactoryBot.define do
  factory :candidate_profile do
    user

    first_name { "Anna" }
    last_name { "de Vries" }
    sequence(:email) { |n| "anna#{n}@example.com" }
    phone_number { "+31 6 12345678" }
    city { "Amsterdam" }
    country { "Netherlands" }
    job_function { "dental_hygienist" }
    preferred_regions { [ "noord_holland" ] }
    max_travel_time { 45 }
    transport_types { [ "car" ] }
    search_status { "active" }
    employment_types { [ "employed" ] }
    years_of_experience { 5.0 }
    available_working_days { %w[monday tuesday wednesday] }
    available_from { Date.current }
  end
end
