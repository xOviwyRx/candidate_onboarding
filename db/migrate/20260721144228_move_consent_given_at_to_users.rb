class MoveConsentGivenAtToUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :candidate_profiles, :consent_given_at, :datetime
    add_column :users, :consent_given_at, :datetime
  end
end
