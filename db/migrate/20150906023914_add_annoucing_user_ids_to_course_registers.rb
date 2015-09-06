class AddAnnoucingUserIdsToCourseRegisters < ActiveRecord::Migration
  def change
    add_column :course_registers, :annoucing_user_ids, :text
  end
end
