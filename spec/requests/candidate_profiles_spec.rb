require "rails_helper"

RSpec.describe "CandidateProfiles", type: :request do
  let(:user) { create(:user) }

  let(:valid_attributes) do
    {
      first_name: "Anna",
      last_name: "de Vries",
      email: "anna@example.com",
      phone_number: "+31 6 12345678",
      city: "Amsterdam",
      job_function: "dental_assistant",
      search_status: "active",
      max_travel_time: 45,
      desired_gross_salary: 3500,
      years_of_experience: 5,
      available_from: Date.current,
      preferred_regions: [ "noord_holland" ],
      employment_types: [ "employed" ],
      available_working_days: %w[monday tuesday],
      candidate_languages_attributes: [ { language_id: create(:language).id, level: "native" } ],
      consent: "1"
    }
  end

  def sign_in(user)
    post session_path, params: { email: user.email, password: "secret123" }
  end

  describe "GET /candidate_profile/new" do
    it "redirects a visitor who is not signed in" do
      get new_candidate_profile_path

      expect(response).to redirect_to(new_session_path)
    end

    it "renders the form for a signed in candidate" do
      sign_in(user)

      get new_candidate_profile_path

      expect(response).to have_http_status(:ok)
    end

    it "prefills the fields read from the candidate's CV" do
      sign_in(user)
      create(:candidate_document, user: user, parsing_status: :completed, parsed_at: Time.current,
                                  parsed_data: { "city" => "Amsterdam", "big_number" => "89123456789" })

      get new_candidate_profile_path

      aggregate_failures do
        expect(response.body).to include("Amsterdam")
        expect(response.body).to include("89123456789")
      end
    end

    it "labels where each prefilled field came from" do
      sign_in(user)
      create(:candidate_document, user: user, parsing_status: :completed, parsed_at: Time.current,
                                  parsed_data: { "email" => "anna@example.com", "first_name" => "Anna" })

      get new_candidate_profile_path

      aggregate_failures do
        expect(response.body).to include(FieldProvenance::EXTRACTED)
        expect(response.body).to include(FieldProvenance::CHECK)
        expect(response.body).to include(FieldProvenance::MISSING)
      end
    end

    it "labels the languages and skills sections the parser filled in" do
      sign_in(user)
      create(:language, name: "Dutch")
      create(:candidate_document, user: user, parsing_status: :completed, parsed_at: Time.current,
                                  parsed_data: {
                                    "languages" => [ { "name" => "Dutch", "level" => "native" } ],
                                    "skills" => [ "Periodontology" ]
                                  })

      get new_candidate_profile_path

      expect(response.body.scan(FieldProvenance::EXTRACTED).count).to eq(2)
    end

    it "labels nothing for a candidate who never uploaded a CV" do
      sign_in(user)

      get new_candidate_profile_path

      expect(response.body).not_to include(FieldProvenance::MISSING)
    end

    it "prefills the education and work experience rows read from the CV" do
      sign_in(user)
      create(:candidate_document, user: user, parsing_status: :completed, parsed_at: Time.current,
                                  parsed_data: {
                                    "educations" => [ { "study" => "Mondzorgkunde" } ],
                                    "work_experiences" => [ { "job_title" => "Dental Hygienist" } ]
                                  })

      get new_candidate_profile_path

      aggregate_failures do
        expect(response.body).to include("Mondzorgkunde")
        expect(response.body).to include("Dental Hygienist")
      end
    end

    it "renders an empty form when no CV was parsed, so the candidate can continue manually" do
      sign_in(user)

      get new_candidate_profile_path

      expect(response).to have_http_status(:ok)
    end

    it "redirects to the profile when the candidate already has one" do
      sign_in(user)
      create(:candidate_profile, user: user)

      get new_candidate_profile_path

      expect(response).to redirect_to(candidate_profile_path)
    end
  end

  describe "POST /candidate_profile" do
    before { sign_in(user) }

    it "creates the profile for the signed in candidate" do
      expect {
        post candidate_profile_path, params: { candidate_profile: valid_attributes }
      }.to change(CandidateProfile, :count).by(1)

      expect(user.reload.candidate_profile).to be_present
    end

    it "redirects to the saved profile" do
      post candidate_profile_path, params: { candidate_profile: valid_attributes }

      expect(response).to redirect_to(candidate_profile_path)
    end

    it "re-renders the form when a required field is missing" do
      post candidate_profile_path, params: { candidate_profile: valid_attributes.merge(city: "") }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "does NOT create a profile when the form is invalid" do
      expect {
        post candidate_profile_path, params: { candidate_profile: valid_attributes.merge(city: "") }
      }.not_to change(CandidateProfile, :count)
    end

    it "saves every education and work experience row submitted with the profile" do
      post candidate_profile_path, params: { candidate_profile: valid_attributes.merge(
        educations_attributes: {
          "0" => { study: "Mondzorgkunde", institution: "Hogeschool Utrecht" },
          "1" => { study: "Tandheelkunde", institution: "ACTA" }
        },
        work_experiences_attributes: {
          "0" => { job_title: "Dental Hygienist", company_name: "Tandartspraktijk Centrum" },
          "1" => { job_title: "Dental Assistant", company_name: "Praktijk Noord" }
        }
      ) }

      profile = user.reload.candidate_profile

      aggregate_failures do
        expect(profile.educations.pluck(:study)).to contain_exactly("Mondzorgkunde", "Tandheelkunde")
        expect(profile.work_experiences.pluck(:job_title)).to contain_exactly("Dental Hygienist", "Dental Assistant")
      end
    end

    it "refuses to save when a candidate who never uploaded a CV has not consented" do
      post candidate_profile_path, params: { candidate_profile: valid_attributes.except(:consent) }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it "does NOT ask again for consent already given at upload" do
      user.record_consent

      post candidate_profile_path, params: { candidate_profile: valid_attributes.except(:consent) }

      expect(response).to redirect_to(candidate_profile_path)
    end

    it "saves the optional fields only the candidate can fill in" do
      post candidate_profile_path, params: { candidate_profile: valid_attributes.merge(
        transport_types: [ "bike" ], notice_period: "one month",
        motivation_for_employer: "I want a smaller practice.", internal_notes: "Prefers mornings."
      ) }

      profile = user.reload.candidate_profile

      aggregate_failures do
        expect(profile.transport_types).to eq([ "bike" ])
        expect(profile.notice_period).to eq("one month")
        expect(profile.internal_notes).to eq("Prefers mornings.")
      end
    end

    it "attaches the CV uploaded earlier to the profile it belongs to" do
      document = create(:candidate_document, user: user)

      post candidate_profile_path, params: { candidate_profile: valid_attributes }

      expect(document.reload.candidate_profile).to eq(user.reload.candidate_profile)
    end

    it "notifies the recruitment team without making the candidate wait for it" do
      expect {
        post candidate_profile_path, params: { candidate_profile: valid_attributes }
      }.to have_enqueued_mail(RecruitmentMailer, :candidate_onboarding_completed)
    end

    it "saves the skills the candidate ticked" do
      skill = create(:skill)

      post candidate_profile_path, params: { candidate_profile: valid_attributes.merge(skill_ids: [ skill.id ]) }

      expect(user.reload.candidate_profile.skills).to contain_exactly(skill)
    end

    it "saves the languages submitted with the profile" do
      post candidate_profile_path, params: { candidate_profile: valid_attributes }

      expect(user.reload.candidate_profile.candidate_languages.first.level).to eq("native")
    end

    context "with rows the candidate left blank" do
      it "does NOT save them" do
        post candidate_profile_path, params: { candidate_profile: valid_attributes.merge(
          educations_attributes: {
            "0" => { study: "", institution: "", location: "", level: "", start_date: "", end_date: "" }
          },
          work_experiences_attributes: {
            "0" => { job_title: "", company_name: "", responsibilities: "", start_date: "", end_date: "" }
          }
        ) }

        profile = user.reload.candidate_profile

        aggregate_failures do
          expect(profile.educations).to be_empty
          expect(profile.work_experiences).to be_empty
        end
      end
    end
  end

  describe "GET /candidate_profile" do
    it "shows the candidate their profile" do
      sign_in(user)
      create(:candidate_profile, user: user)

      get candidate_profile_path

      expect(response).to have_http_status(:ok)
    end

    it "shows the candidate's education and work experience" do
      sign_in(user)
      profile = create(:candidate_profile, user: user)
      create(:education, candidate_profile: profile, study: "Mondzorgkunde")
      create(:work_experience, candidate_profile: profile, job_title: "Dental Hygienist")

      get candidate_profile_path

      aggregate_failures do
        expect(response.body).to include("Mondzorgkunde")
        expect(response.body).to include("Dental Hygienist")
      end
    end

    it "redirects to the form when the candidate has no profile yet" do
      sign_in(user)

      get candidate_profile_path

      expect(response).to redirect_to(new_candidate_profile_path)
    end
  end
end
