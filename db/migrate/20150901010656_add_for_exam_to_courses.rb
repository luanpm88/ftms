class AddForExamToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :for_exam_year, :integer
    add_column :courses, :for_exam_month, :string
  end
end
