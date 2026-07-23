class CandidateProfilesController < ApplicationController
  # Scalar fields a parsed CV can fill in directly. Educations, work experiences,
  # skills and languages are nested and are prefilled separately.
  PREFILLABLE = %w[
    first_name last_name email phone_number city country
    job_function years_of_experience professional_summary
    big_number big_registration_status
  ].freeze

  EDUCATION_FIELDS = %w[institution study location level start_date end_date].freeze
  WORK_EXPERIENCE_FIELDS = %w[job_title company_name responsibilities start_date end_date current_job].freeze
  LANGUAGE_FIELDS = %w[language_id level].freeze

  before_action :require_sign_in
  before_action :redirect_to_profile, only: %i[new create], if: -> { current_user.candidate_profile }

  def new
    @candidate_profile = current_user.build_candidate_profile(prefilled_attributes)
    @provenance = FieldProvenance.new(parsed_cv)
    prefill_nested_records
  end

  def create
    @candidate_profile = current_user.build_candidate_profile(candidate_profile_params)

    if @candidate_profile.save
      current_user.record_consent
      RecruitmentMailer.candidate_onboarding_completed(@candidate_profile).deliver_later
      redirect_to candidate_profile_path, notice: "Your profile has been saved."
    else
      @provenance = FieldProvenance.new(parsed_cv)
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

  # Rows found in the CV are prefilled with what it said. When the CV had none, one
  # empty row is added so the candidate has a blank set of fields to type into.
  # No values are ever invented.
  def prefill_nested_records
    parsed_rows("educations", EDUCATION_FIELDS).each { |attrs| @candidate_profile.educations.build(attrs) }
    parsed_rows("work_experiences", WORK_EXPERIENCE_FIELDS).each { |attrs| @candidate_profile.work_experiences.build(attrs) }

    prefill_languages
    prefill_skills

    @candidate_profile.educations.build if @candidate_profile.educations.empty?
    @candidate_profile.work_experiences.build if @candidate_profile.work_experiences.empty?
    @candidate_profile.candidate_languages.build if @candidate_profile.candidate_languages.empty?
  end

  # §3.6: the parser already matched against the seeded list, so the names come
  # back straight off it and only need turning into ids for the check boxes.
  def prefill_skills
    names = parsed_cv["skills"]
    return unless names.is_a?(Array)

    @candidate_profile.skill_ids = Skill.where(name: names).ids
  end

  # The parser returns platform language names; only ones actually seeded are
  # built, so a language the platform does not offer is dropped rather than
  # breaking the form.
  def prefill_languages
    rows = parsed_cv["languages"]
    return unless rows.is_a?(Array)

    seeded = Language.where(name: rows.filter_map { |row| row["name"] }).index_by(&:name)

    rows.each do |row|
      language = seeded[row["name"]]
      next if language.nil?

      @candidate_profile.candidate_languages.build(language: language, level: row["level"])
    end
  end

  # Slicing to known columns keeps anything unexpected in the parser output from
  # reaching build, which would raise UnknownAttributeError and break the form.
  def parsed_rows(key, fields)
    rows = parsed_cv[key]
    return [] unless rows.is_a?(Array)

    rows.filter_map { |row| row.slice(*fields) if row.is_a?(Hash) }
  end

  def parsed_cv
    current_user.candidate_documents.completed.order(:parsed_at).last&.parsed_data || {}
  end

  def candidate_profile_params
    params.require(:candidate_profile).permit(
      :first_name, :last_name, :email, :phone_number, :city, :country,
      :job_function, :search_status, :max_travel_time, :years_of_experience,
      :available_from, :professional_summary,
      :desired_gross_salary, :desired_percentage, :average_daily_revenue,
      :big_registration_status, :big_number, :consent,
      :notice_period, :motivation_for_employer, :internal_notes, :reason_for_looking,
      preferred_regions: [], employment_types: [], available_working_days: [], skill_ids: [],
      transport_types: [],
      educations_attributes: EDUCATION_FIELDS,
      work_experiences_attributes: WORK_EXPERIENCE_FIELDS,
      candidate_languages_attributes: LANGUAGE_FIELDS
    )
  end
end
