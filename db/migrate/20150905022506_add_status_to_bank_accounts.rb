class AddStatusToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :status, :text
  end
end
