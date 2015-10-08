class AddNoteToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :note, :text
  end
end
