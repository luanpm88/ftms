class AddStatusToBooks < ActiveRecord::Migration
  def change
    add_column :books, :status, :text
  end
end
