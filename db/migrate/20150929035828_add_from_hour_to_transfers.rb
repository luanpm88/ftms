class AddFromHourToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :from_hour, :text
  end
end
