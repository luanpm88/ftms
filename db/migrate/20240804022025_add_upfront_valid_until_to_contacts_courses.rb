class AddUpfrontValidUntilToContactsCourses < ActiveRecord::Migration
  def change
    add_column :contacts_courses, :upfront_valid_until, :datetime
  end
end
