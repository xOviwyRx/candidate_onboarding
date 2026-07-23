class AddSynonymsToSkills < ActiveRecord::Migration[8.0]
  def change
    add_column :skills, :synonyms, :string, array: true, default: [], null: false
  end
end
