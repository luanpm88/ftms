class AddVaidFromToBooks < ActiveRecord::Migration
  def change
    add_column :books, :valid_from, :datetime
  end
end
