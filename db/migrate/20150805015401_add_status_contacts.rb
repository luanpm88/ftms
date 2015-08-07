class AddStatusContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :status, :text
  end
end
