class AddItemCodeToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :item_code, :string
  end
end
