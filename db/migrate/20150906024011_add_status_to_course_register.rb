class AddStatusToCourseRegister < ActiveRecord::Migration
  def change
    add_column :course_registers, :status, :text
  end
end
