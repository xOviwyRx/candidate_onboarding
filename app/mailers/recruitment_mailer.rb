class RecruitmentMailer < ApplicationMailer
  # §10: the recruitment team is notified once a candidate finishes onboarding.
  # The address is configuration rather than a user record — this module has no
  # admin accounts of its own, they live on the wider platform.
  RECIPIENT = ENV.fetch("RECRUITMENT_TEAM_EMAIL", "recruitment@example.com")

  # Named for §10's suggested event, so the mail and a later webhook agree.
  def candidate_onboarding_completed(candidate_profile)
    @candidate_profile = candidate_profile

    mail to: RECIPIENT,
         subject: "New candidate: #{candidate_profile.first_name} #{candidate_profile.last_name}"
  end
end
