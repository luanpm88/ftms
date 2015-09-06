class AddAnnoucingUserIdsToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :annoucing_user_ids, :text
  end
end
