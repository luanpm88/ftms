class AddTypeToDiscountPrograms < ActiveRecord::Migration
  def change
    add_column :discount_programs, :type_name, :string
  end
end
