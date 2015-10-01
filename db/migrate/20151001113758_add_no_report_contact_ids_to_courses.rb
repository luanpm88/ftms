class AddNoReportContactIdsToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :no_report_contact_ids, :text
  end
end
