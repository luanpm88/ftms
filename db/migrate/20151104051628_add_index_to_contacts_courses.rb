class AddIndexToContactsCourses < ActiveRecord::Migration
  def change
    add_index :contacts_courses, :courses_phrase_ids
  end
end
