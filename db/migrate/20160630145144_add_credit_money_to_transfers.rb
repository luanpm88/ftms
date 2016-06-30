class AddCreditMoneyToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :credit_money, :decimal
  end
end
