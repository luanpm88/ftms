class AddCanceledToBooksContact < ActiveRecord::Migration
  def change
    add_column :books_contacts, :canceled, :boolean, default: false
  end
end
