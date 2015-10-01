class AddHourMoneyToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :hour_money, :decimal
  end
end
