require "rails_helper"

RSpec.describe RecruitmentMailer, type: :mailer do
  describe "candidate_onboarding_completed" do
    subject(:mail) { described_class.candidate_onboarding_completed(profile) }

    let(:profile) { create(:candidate_profile, first_name: "Anna", last_name: "de Vries") }

    it "names the candidate in the subject" do
      expect(mail.subject).to eq("New candidate: Anna de Vries")
    end

    it "goes to the recruitment team rather than to a user record" do
      expect(mail.to).to eq([ described_class::RECIPIENT ])
    end

    it "summarises the profile, so the team need not open the app to triage it" do
      expect(mail.body.to_s).to include(profile.email, profile.job_function.humanize)
    end
  end
end
