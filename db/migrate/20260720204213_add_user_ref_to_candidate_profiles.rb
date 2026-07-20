class AddUserRefToCandidateProfiles < ActiveRecord::Migration[8.0]
  def change
    add_reference :candidate_profiles, :user, null: false, foreign_key: true, index: { unique: true }
  end
end
