class AddRemarkToAdminToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :remark_to_admin, :text
  end
end
