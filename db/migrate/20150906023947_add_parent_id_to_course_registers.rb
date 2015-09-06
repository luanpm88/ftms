class AddParentIdToCourseRegisters < ActiveRecord::Migration
  def change
    add_column :course_registers, :parent_id, :integer
  end
end
