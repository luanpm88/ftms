class AddDisplayOrderToContactTypes < ActiveRecord::Migration
  def change
    add_column :contact_types, :display_order, :integer
  end
end
