class AddPreferredMailing2ToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :preferred_mailing, :string
  end
end
