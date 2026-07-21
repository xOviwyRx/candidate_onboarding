class CreateWorkExperiences < ActiveRecord::Migration[8.0]
  def change
    create_table :work_experiences do |t|
      t.references :candidate_profile, null: false, foreign_key: true

      t.string  :job_title,    null: false
      t.string  :company_name, null: false
      t.text    :responsibilities
      t.date    :start_date
      t.date    :end_date
      t.boolean :current_job, null: false, default: false

      t.timestamps
    end
  end
end
