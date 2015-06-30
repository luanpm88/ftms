class AddMobile2ToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :mobile_2, :string
  end
end
