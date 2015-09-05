class AddStatusToCourseTypes < ActiveRecord::Migration
  def change
    add_column :course_types, :status, :text
  end
end
