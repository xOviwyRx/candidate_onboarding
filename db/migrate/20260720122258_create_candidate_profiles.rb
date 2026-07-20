class CreateCandidateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate_profiles do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone_number, null: false
      t.string :city, null: false
      t.string :country
      t.string :job_function, null: false
      t.string :preferred_regions, array: true, default: [], null: false
      t.integer :max_travel_time, null: false
      t.string :transport_types, array: true, default: [], null: false
      t.string :search_status, null: false
      t.text :reason_for_looking
      t.string :employment_types, array: true, default: [], null: false
      t.decimal :desired_gross_salary, precision: 10, scale: 2
      t.decimal :desired_percentage, precision: 5, scale: 2
      t.decimal :average_daily_revenue, precision: 10, scale: 2
      t.string :big_registration_status
      t.string :big_number
      t.decimal :years_of_experience, precision: 3, scale: 1, null: false
      t.string :available_working_days, array: true, default: [], null: false
      t.date :available_from, null: false
      t.string :notice_period
      t.text :motivation_for_employer
      t.text :internal_notes
      t.text :professional_summary
      t.datetime :consent_given_at

      t.timestamps
    end

    add_index :candidate_profiles, :email, unique: true
    add_index :candidate_profiles, :job_function
    add_index :candidate_profiles, :search_status
  end
end
