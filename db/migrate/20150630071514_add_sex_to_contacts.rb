class AddSexToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :sex, :string
  end
end
