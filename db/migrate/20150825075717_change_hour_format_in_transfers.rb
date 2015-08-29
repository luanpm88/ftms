class ChangeHourFormatInTransfers < ActiveRecord::Migration
  def change
    change_column :transfers, :hour, :decimal
  end
end
