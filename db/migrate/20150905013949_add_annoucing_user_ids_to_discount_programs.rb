class AddAnnoucingUserIdsToDiscountPrograms < ActiveRecord::Migration
  def change
    add_column :discount_programs, :annoucing_user_ids, :text
  end
end
