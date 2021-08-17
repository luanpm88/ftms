class AddSourceToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :source, :text
  end
end
