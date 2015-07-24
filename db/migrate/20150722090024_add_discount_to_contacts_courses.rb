class AddDiscountToContactsCourses < ActiveRecord::Migration
  def change
    add_column :contacts_courses, :discount, :decimal
  end
end
