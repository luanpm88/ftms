class CreateSalesTargets < ActiveRecord::Migration
  def change
    create_table :sales_targets do |t|
      t.integer :staff_id
      t.integer :report_period_id
      t.integer :user_id
      t.decimal :amount
      t.string :status

      t.timestamps null: false
    end
  end
end
