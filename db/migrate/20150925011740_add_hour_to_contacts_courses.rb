class AddHourToContactsCourses < ActiveRecord::Migration
  def change
    add_column :contacts_courses, :hour, :decimal
  end
end
