class AddReferrerIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :referrer_id, :integer
  end
end
