class AddOtherDiscountsToContactsCourses < ActiveRecord::Migration
  def change
    add_column :contacts_courses, :other_discounts, :text
  end
end
