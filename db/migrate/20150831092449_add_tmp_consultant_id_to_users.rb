class AddTmpConsultantIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tmp_ConsultantID, :text
  end
end
