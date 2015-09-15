class CreateCourseTypesDiscountPrograms < ActiveRecord::Migration
  def change
    create_table :course_types_discount_programs do |t|
      t.integer :course_type_id
      t.integer :discount_program_id

      t.timestamps null: false
    end
  end
end
