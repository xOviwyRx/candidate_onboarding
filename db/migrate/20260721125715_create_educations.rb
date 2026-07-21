class CreateEducations < ActiveRecord::Migration[8.0]
  def change
    create_table :educations do |t|
      t.references :candidate_profile, null: false, foreign_key: true

      t.string :institution
      t.string :study, null: false
      t.string :location
      t.string :level
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
