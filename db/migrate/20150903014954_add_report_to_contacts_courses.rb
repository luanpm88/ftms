class AddReportToContactsCourses < ActiveRecord::Migration
  def change
    add_column :contacts_courses, :report, :boolean, default: true
  end
end
