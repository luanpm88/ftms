class AddUpfrontToContactsCourses < ActiveRecord::Migration
  def change
    add_column :contacts_courses, :upfront, :boolean
  end
end
