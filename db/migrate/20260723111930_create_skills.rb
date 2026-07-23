class CreateSkills < ActiveRecord::Migration[8.0]
  def change
    create_table :skills do |t|
      t.string :name, null: false
      t.string :job_functions, array: true, default: [], null: false

      t.timestamps
    end

    add_index :skills, :name, unique: true
  end
end
