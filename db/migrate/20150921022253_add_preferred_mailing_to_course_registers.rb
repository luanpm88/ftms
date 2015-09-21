class AddPreferredMailingToCourseRegisters < ActiveRecord::Migration
  def change
    add_column :course_registers, :preferred_mailing, :string
  end
end
