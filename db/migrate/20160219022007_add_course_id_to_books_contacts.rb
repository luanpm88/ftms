class AddCourseIdToBooksContacts < ActiveRecord::Migration
  def change
    add_column :books_contacts, :course_id, :integer
  end
end
