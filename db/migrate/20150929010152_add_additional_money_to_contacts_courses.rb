class AddAdditionalMoneyToContactsCourses < ActiveRecord::Migration
  def change
    add_column :contacts_courses, :additional_money, :decimal
  end
end
