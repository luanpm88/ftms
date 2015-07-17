class AddPresentToContactsSeminars < ActiveRecord::Migration
  def change
    add_column :contacts_seminars, :present, :boolean, default: false
  end
end
