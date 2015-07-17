class CreateContactsCourseTypes < ActiveRecord::Migration
  def change
    create_table :contacts_course_types do |t|
      t.integer :contact_id
      t.integer :course_type_id

      t.timestamps null: false
    end
  end
end
