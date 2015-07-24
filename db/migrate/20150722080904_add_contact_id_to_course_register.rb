class AddContactIdToCourseRegister < ActiveRecord::Migration
  def change
    add_column :course_registers, :contact_id, :integer
  end
end
