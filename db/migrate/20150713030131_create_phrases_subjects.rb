class CreatePhrasesSubjects < ActiveRecord::Migration
  def change
    create_table :phrases_subjects do |t|
      t.integer :phrase_id
      t.integer :subject_id

      t.timestamps null: false
    end
  end
end
