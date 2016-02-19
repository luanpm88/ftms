class AddIsLecturerNoteToStockTypes < ActiveRecord::Migration
  def change
    add_column :stock_types, :is_lecturer_note, :boolean, default: false
  end
end
