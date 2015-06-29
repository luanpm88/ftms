class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.text :description
      t.integer :user_id
      t.integer :course_type_id
      t.date :intake

      t.timestamps null: false
    end
  end
end
