class AddStatusToDiscountProgram < ActiveRecord::Migration
  def change
    add_column :discount_programs, :status, :text
  end
end
