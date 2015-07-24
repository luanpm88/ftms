class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :name
      t.text :bank_name
      t.text :account_name
      t.string :account_number
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
