class AddVaidToToBooks < ActiveRecord::Migration
  def change
    add_column :books, :valid_to, :datetime
  end
end
