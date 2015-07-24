class AddBankAccountIdToCourseRegister < ActiveRecord::Migration
  def change
    add_column :course_registers, :bank_account_id, :integer
  end
end
