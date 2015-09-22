class AddCourseTypeIdToPaymentRecordDetails < ActiveRecord::Migration
  def change
    add_column :payment_record_details, :course_type_id, :integer
  end
end
