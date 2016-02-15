class CreateReportPeriods < ActiveRecord::Migration
  def change
    create_table :report_periods do |t|
      t.integer :user_id
      t.string :name
      t.datetime :start_at
      t.datetime :end_at
      t.string :status

      t.timestamps null: false
    end
  end
end
