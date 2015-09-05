class AddParentIdToDiscountPrograms < ActiveRecord::Migration
  def change
    add_column :discount_programs, :parent_id, :integer
  end
end
