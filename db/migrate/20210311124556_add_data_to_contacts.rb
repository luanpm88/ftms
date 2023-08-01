class AddDataToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :data, :text, default: "{}"
  end
end
