class AddParentIdToPhrases < ActiveRecord::Migration
  def change
    add_column :phrases, :parent_id, :integer
  end
end
