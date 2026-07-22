class CandidateProfilesController < ApplicationController
  # Scalar fields a parsed CV can fill in directly. Educations, work experiences,
  # skills and languages are nested and are prefilled separately.
  PREFILLABLE = %w[
    first_name last_name email phone_number city country
    job_function years_of_experience professional_summary
  ].freeze

  before_action :require_sign_in
  before_action :redirect_to_profile, only: %i[new create], if: -> { current_user.candidate_profile }

  def new
    @candidate_profile = current_user.build_candidate_profile(prefilled_attributes)
  end

  def create
    @candidate_profile = current_user.build_candidate_profile(candidate_profile_params)

    if @candidate_profile.save
      redirect_to candidate_profile_path, notice: "Your profile has been saved."
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @candidate_profile = current_user.candidate_profile

    redirect_to new_candidate_profile_path unless @candidate_profile
  end

  private

  def redirect_to_profile
    redirect_to candidate_profile_path
  end

  def prefilled_attributes
    parsed_cv.slice(*PREFILLABLE)
  end

  def parsed_cv
    current_user.candidate_documents.completed.order(:parsed_at).last&.parsed_data || {}
  end

  def candidate_profile_params
    params.require(:candidate_profile).permit(
      :first_name, :last_name, :email, :phone_number, :city, :country,
      :job_function, :search_status, :max_travel_time, :years_of_experience,
      :available_from, :professional_summary,
      preferred_regions: [], employment_types: [], available_working_days: []
    )
  end
end
