class CreateContactsCourses < ActiveRecord::Migration
  def change
    create_table :contacts_courses do |t|
      t.integer :contact_id
      t.integer :course_id
      t.integer :course_register_id

      t.timestamps null: false
    end
  end
end
