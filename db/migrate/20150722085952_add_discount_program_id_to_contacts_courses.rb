class AddDiscountProgramIdToContactsCourses < ActiveRecord::Migration
  def change
    add_column :contacts_courses, :discount_program_id, :integer
  end
end
