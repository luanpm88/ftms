class AddStatusToPhrases < ActiveRecord::Migration
  def change
    add_column :phrases, :status, :text
  end
end
