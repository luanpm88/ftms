class CreateCourseRegisters < ActiveRecord::Migration
  def change
    create_table :course_registers do |t|
      t.datetime :created_date
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
