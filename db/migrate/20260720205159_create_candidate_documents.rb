class CreateCandidateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate_documents do |t|
      t.references :user, null: false, foreign_key: true
      t.references :candidate_profile, null: true, foreign_key: true

      t.string :document_type, null: false
      t.string :original_filename, null: false
      t.string :content_type, null: false
      t.integer :file_size, null: false
      t.datetime :parsed_at
      t.string :parsing_status, null: false, default: "pending"
      t.jsonb :parsed_data, null: false, default: {}

      t.timestamps
    end
  end
end
