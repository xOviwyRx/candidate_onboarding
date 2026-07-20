FactoryBot.define do
  factory :candidate_profile do
    first_name { "MyString" }
    last_name { "MyString" }
    email { "MyString" }
    phone_number { "MyString" }
    city { "MyString" }
    country { "MyString" }
    job_function { "MyString" }
    preferred_regions { "MyString" }
    max_travel_time { 1 }
    transport_types { "MyString" }
    search_status { "MyString" }
    reason_for_looking { "MyText" }
    employment_types { "MyString" }
    desired_gross_salary { "9.99" }
    desired_percentage { "9.99" }
    average_daily_revenue { "9.99" }
    big_registration_status { "MyString" }
    big_number { "MyString" }
    years_of_experience { "9.99" }
    available_working_days { "MyString" }
    available_from { "2026-07-20" }
    notice_period { "MyString" }
    motivation_for_employer { "MyText" }
    internal_notes { "MyText" }
    professional_summary { "MyText" }
    consent_given_at { "2026-07-20 14:22:59" }
  end
end
