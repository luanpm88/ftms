class AddAnnoucingUserIdsToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :annoucing_user_ids, :text
  end
end
