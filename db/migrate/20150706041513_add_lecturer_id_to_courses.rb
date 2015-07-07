class AddLecturerIdToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :lecturer_id, :integer
  end
end
