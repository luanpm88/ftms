class CreateOldUserRoles < ActiveRecord::Migration
  def change
    create_table :old_user_roles do |t|
      t.text :user_role_id
      t.text :user_role
      t.text :user_role_detail

      t.timestamps null: false
    end
  end
end
