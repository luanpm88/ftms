class AddBasesToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :bases, :text
  end
end
