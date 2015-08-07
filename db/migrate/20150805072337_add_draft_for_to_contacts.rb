class AddDraftForToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :draft_for, :integer
  end
end
