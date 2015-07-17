class AddCoursesPhraseIdsToContactsCourse < ActiveRecord::Migration
  def change
    add_column :contacts_courses, :courses_phrase_ids, :string
  end
end
