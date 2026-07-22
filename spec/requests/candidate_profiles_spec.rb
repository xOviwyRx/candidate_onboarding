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
      job_function: "dental_hygienist",
      search_status: "active",
      max_travel_time: 45,
      years_of_experience: 5,
      available_from: Date.current,
      preferred_regions: [ "noord_holland" ],
      employment_types: [ "employed" ],
      available_working_days: %w[monday tuesday]
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
                                  parsed_data: { "first_name" => "Anna", "city" => "Amsterdam" })

      get new_candidate_profile_path

      expect(response.body).to include("Amsterdam")
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
  end

  describe "GET /candidate_profile" do
    it "shows the candidate their profile" do
      sign_in(user)
      create(:candidate_profile, user: user)

      get candidate_profile_path

      expect(response).to have_http_status(:ok)
    end

    it "redirects to the form when the candidate has no profile yet" do
      sign_in(user)

      get candidate_profile_path

      expect(response).to redirect_to(new_candidate_profile_path)
    end
  end
end
