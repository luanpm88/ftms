class AddDiscountProgramsToBooksContacts < ActiveRecord::Migration
  def change
    add_column :books_contacts, :discount_programs, :text
  end
end
