class AddAnnoucingUserIdsToTransfers < ActiveRecord::Migration
  def change
    add_column :transfers, :annoucing_user_ids, :text
  end
end
