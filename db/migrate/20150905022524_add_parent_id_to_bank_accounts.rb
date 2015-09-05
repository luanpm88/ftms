class AddParentIdToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :parent_id, :integer
  end
end
