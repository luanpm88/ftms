class AddPriceToContactsCourses < ActiveRecord::Migration
  def change
    add_column :contacts_courses, :price, :decimal
  end
end
