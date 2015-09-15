class AddDiscountProgramsToContactsCourses < ActiveRecord::Migration
  def change
    add_column :contacts_courses, :discount_programs, :text
  end
end
