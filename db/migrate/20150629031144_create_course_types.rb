class CreateCourseTypes < ActiveRecord::Migration
  def change
    create_table :course_types do |t|
      t.string :name
      t.string :short_name
      t.text :description
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
