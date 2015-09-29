class AddAccountManagerIdToCourseRegisters < ActiveRecord::Migration
  def change
    add_column :course_registers, :account_manager_id, :integer
  end
end
