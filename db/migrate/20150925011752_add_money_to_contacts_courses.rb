class AddMoneyToContactsCourses < ActiveRecord::Migration
  def change
    add_column :contacts_courses, :money, :decimal
  end
end
