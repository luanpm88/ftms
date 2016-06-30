class AddMoneyCreditToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :money_credit, :decimal
  end
end
