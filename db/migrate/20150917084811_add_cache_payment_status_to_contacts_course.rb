class AddCachePaymentStatusToContactsCourse < ActiveRecord::Migration
  def change
    add_column :contacts_courses, :cache_payment_status, :text
  end
end
