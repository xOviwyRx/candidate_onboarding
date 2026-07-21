FactoryBot.define do
  factory :education do
    candidate_profile

    institution { "Hogeschool Utrecht" }
    study { "Mondzorgkunde" }
    location { "Utrecht, Netherlands" }
    level { "hbo" }
    start_date { Date.new(2015, 9, 1) }
    end_date { Date.new(2019, 6, 30) }
  end
end
