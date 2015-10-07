class CreateOldUserLevels < ActiveRecord::Migration
  def change
    create_table :old_user_levels do |t|
      t.text :user_permission_id
      t.text :user_name
      t.text :user_role
      t.text :consultant_id
      t.text :in_charge

      t.timestamps null: false
    end
  end
end
