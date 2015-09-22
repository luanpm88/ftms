class AddCourseRegisterIdsToPaymentRecords < ActiveRecord::Migration
  def change
    add_column :payment_records, :course_register_ids, :text
  end
end
